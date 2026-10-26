// Pomelu's Bot Screen viewer: noVNC's RFB client in the app's web view.
//
// The app (lib/features/bot_screen) drives it through `window.pomelu` and
// hears back on the `Pomelu` JavaScript channel. It dials the display socket
// itself, so it knows the close code (noVNC's `disconnect` carries only
// `clean`), and it keeps zoom and pan local: a pinch never reaches the bot's
// desktop. While the bot is in control every gesture moves the view; once
// you are, one finger is the mouse and two fingers scroll, or pan a zoomed
// view. With Drag on, a tap picks up what is under it, every gesture then
// moves the view, and the next tap drops it there.
//
// The home view suits the window: whole on a wide one; on a tall one (a
// phone held up, a folded cover screen) the desktop fills the height
// instead of showing as a thin strip, and the view follows what changes on
// the desktop, which is where the bot works. A pinch or a pan stops the
// following; a double tap goes home again. Build:
// `node tool/bot_screen/build.mjs`.

import RFB from './node_modules/@novnc/novnc/core/rfb.js';
import KeyTable from './node_modules/@novnc/novnc/core/input/keysym.js';
import keysyms from './node_modules/@novnc/novnc/core/input/keysymdef.js';
import { clientToElement } from './node_modules/@novnc/novnc/core/util/element.js';

// Before the first frame: the Bot Screen's own size (bot_desktop.geometry).
const DEFAULT_FRAME = { w: 1440, h: 900 };
// The closest view shows a desktop pixel this many CSS pixels wide.
const MAX_SCALE = 1.5;
const MIN_MAX_ZOOM = 2;
const DOUBLE_TAP_ZOOM = 2.5;
const DOUBLE_TAP_MS = 300;
const DOUBLE_TAP_SLOP = 40;
// A drop moves the held pointer there in steps, then waits: a desktop
// starts a drag only on motion, and its target answers before the release.
const DROP_STEPS = 12;
const DROP_STEP_MS = 25;
const DROP_SETTLE_MS = 150;
// A tall window's home view fills it when that shows the desktop at least
// this much closer than whole; else home is the whole desktop.
const FILL_MIN_GAIN = 1.25;
// Following: every beat the view moves to what changed in the last one,
// unless that is already well inside it (this share of the view is kept
// clear at each edge).
const FOLLOW_BEAT_MS = 400;
const FOLLOW_MARGIN = 0.12;
// Changes that are no place to follow: the desktop's top panel (its clock)
// and a change of more than this share of the desktop (a page loading).
const PANEL_ROWS = 32;
const MAX_ACTIVITY = 0.5;

const KEYS = {
  escape: [KeyTable.XK_Escape, 'Escape'],
  tab: [KeyTable.XK_Tab, 'Tab'],
  enter: [KeyTable.XK_Return, 'Enter'],
  backspace: [KeyTable.XK_BackSpace, 'Backspace'],
  left: [KeyTable.XK_Left, 'ArrowLeft'],
  up: [KeyTable.XK_Up, 'ArrowUp'],
  right: [KeyTable.XK_Right, 'ArrowRight'],
  down: [KeyTable.XK_Down, 'ArrowDown'],
};
const MODIFIERS = {
  ctrl: [KeyTable.XK_Control_L, 'ControlLeft'],
  alt: [KeyTable.XK_Alt_L, 'AltLeft'],
};

const stage = document.getElementById('stage');
const poster = document.getElementById('poster');

let rfb = null;
let socket = null;
let generation = 0;
let insets = { top: 0, right: 0, bottom: 0, left: 0 };
let motionMs = 240;
// The committed view: the stage is the fit box times `zoom`, offset by
// `panX`/`panY` from the box's corner.
let zoom = 1;
let panX = 0;
let panY = 0;
let gesture = null;
let lastTap = null;
let animation = 0;
let animating = false;
let zoomSent = '';
// At home (the view [homeZoom] gives, moving with the window) and
// following what changes, until a gesture of the person moves the view.
let atHome = true;
let follow = true;
// What changed on the desktop since the last beat, in desktop pixels.
let activity = null;
// Drag: 'off', 'pick' (the next tap picks up) or 'drop' (the left button is
// held at `held`, a point of the desktop as a share of its width and height).
let drag = 'off';
let held = null;

const post = (message) => window.Pomelu?.postMessage(JSON.stringify(message));

window.addEventListener('error', (e) => post({ type: 'error', message: String(e.message) }));

// ------------------------------------------------------------ geometry

/** The window less the app's floating chrome: where the desktop fits. */
function fitBox() {
  return {
    x: insets.left,
    y: insets.top,
    w: Math.max(1, window.innerWidth - insets.left - insets.right),
    h: Math.max(1, window.innerHeight - insets.top - insets.bottom),
  };
}

function frameSize() {
  const canvas = stage.querySelector('canvas');
  return canvas && canvas.width > 0 && canvas.height > 0
    ? { w: canvas.width, h: canvas.height }
    : DEFAULT_FRAME;
}

function fitScale(box = fitBox()) {
  const f = frameSize();
  return Math.min(box.w / f.w, box.h / f.h);
}

function maxZoom() {
  return Math.max(MIN_MAX_ZOOM, MAX_SCALE / fitScale());
}

/** The home zoom: the desktop filling a tall window, else whole (1). */
function homeZoom(box = fitBox()) {
  const f = frameSize();
  const fill = Math.max(box.w / f.w, box.h / f.h) / fitScale(box);
  return fill >= FILL_MIN_GAIN ? Math.min(fill, maxZoom()) : 1;
}

/** One axis of the pan: the desktop centred while it fits, else its edges
 *  kept at the box's. Lengths: `stageLen` the stage's, `content` the
 *  desktop's, `view` the box's. */
function clampAxis(pan, stageLen, content, view) {
  const inset = (stageLen - content) / 2;
  if (content <= view) return (view - content) / 2 - inset;
  return Math.min(0, Math.max(view - content, pan + inset)) - inset;
}

/** The view [z, x, y] clamped to what the desktop covers. */
function clampView(z, x, y) {
  const box = fitBox();
  const f = frameSize();
  const scale = fitScale(box) * z;
  return [
    z,
    clampAxis(x, box.w * z, f.w * scale, box.w),
    clampAxis(y, box.h * z, f.h * scale, box.h),
  ];
}

/** The view at [z] with the desktop point [p] (a share of its width and
 *  height) in the middle of the window, as far as the desktop allows. */
function centerOn(z, p) {
  const box = fitBox();
  const f = frameSize();
  const scale = fitScale(box) * z;
  const cw = f.w * scale;
  const ch = f.h * scale;
  return clampView(
    z,
    box.w / 2 - (box.w * z - cw) / 2 - p.x * cw,
    box.h / 2 - (box.h * z - ch) / 2 - p.y * ch,
  );
}

/** The part of the desktop the window shows now, as shares of it. */
function shown() {
  const canvas = stage.querySelector('canvas');
  const box = fitBox();
  if (!canvas) return { x0: 0, y0: 0, x1: 1, y1: 1 };
  const r = canvas.getBoundingClientRect();
  return {
    x0: (box.x - r.left) / r.width,
    y0: (box.y - r.top) / r.height,
    x1: (box.x + box.w - r.left) / r.width,
    y1: (box.y + box.h - r.top) / r.height,
  };
}

/** Lays the stage out at the committed view; noVNC scales the desktop
 *  into it, so pointer positions map through its own scale. */
function place() {
  [zoom, panX, panY] = clampView(Math.min(Math.max(zoom, 1), maxZoom()), panX, panY);
  const box = fitBox();
  stage.style.width = `${box.w * zoom}px`;
  stage.style.height = `${box.h * zoom}px`;
  stage.style.transform = `translate(${box.x + panX}px, ${box.y + panY}px)`;
  poster.style.left = `${box.x}px`;
  poster.style.top = `${box.y}px`;
  poster.style.width = `${box.w}px`;
  poster.style.height = `${box.h}px`;
  const zoomed = zoom > 1.001;
  const canFill = !zoomed && homeZoom(box) > 1.001;
  const sent = `${zoomed}${canFill}`;
  if (sent !== zoomSent) {
    zoomSent = sent;
    post({ type: 'zoom', zoomed, canFill });
  }
}

/** The window or the desktop changed size: a view at home stays home,
 *  around the same middle; any other keeps its zoom. */
function relayout() {
  if (atHome && !gesture && !animating) {
    const s = shown();
    [zoom, panX, panY] = centerOn(homeZoom(), {
      x: Math.min(1, Math.max(0, (s.x0 + s.x1) / 2)),
      y: Math.min(1, Math.max(0, (s.y0 + s.y1) / 2)),
    });
  }
  place();
}

/** Home, around [p] (a desktop point as shares), following again. */
function goHome(p) {
  atHome = true;
  follow = true;
  animateTo(centerOn(homeZoom(), p));
}

/** The person moved the view: it stays where they put it. */
function moved() {
  atHome = false;
  follow = false;
}

/** A view on the way to [z, x, y]: a transform of the committed stage, so
 *  noVNC does not rescale on every frame of a pinch. */
function preview(z, x, y) {
  const box = fitBox();
  const k = z / zoom;
  stage.style.transform = `translate(${box.x + x}px, ${box.y + y}px) scale(${k})`;
}

function commit(z, x, y) {
  [zoom, panX, panY] = clampView(z, x, y);
  place();
}

/** The view zoomed to [z] with the point at client (cx, cy) kept still. */
function zoomAround(z, cx, cy, from = { zoom, panX, panY }) {
  const box = fitBox();
  const clamped = Math.min(Math.max(z, 1), maxZoom());
  const sx = cx - box.x - from.panX;
  const sy = cy - box.y - from.panY;
  const k = clamped / from.zoom;
  return clampView(clamped, cx - box.x - sx * k, cy - box.y - sy * k);
}

function animateTo(target) {
  cancelAnimationFrame(animation);
  const start = { zoom, panX, panY };
  if (motionMs <= 0) {
    animating = false;
    return commit(...target);
  }
  animating = true;
  const began = performance.now();
  const step = (now) => {
    const t = Math.min(1, (now - began) / motionMs);
    const e = 1 - (1 - t) ** 3; // ease out cubic, as tokens.motion
    const z = start.zoom + (target[0] - start.zoom) * e;
    const x = start.panX + (target[1] - start.panX) * e;
    const y = start.panY + (target[2] - start.panY) * e;
    if (t < 1) {
      preview(z, x, y);
      animation = requestAnimationFrame(step);
    } else {
      animating = false;
      commit(...target);
    }
  };
  animation = requestAnimationFrame(step);
}

// ------------------------------------------------------------ gestures

function watching() {
  return !rfb || rfb.viewOnly;
}

/** Every gesture moves the view: while watching, and while Drag is on. */
function viewing() {
  return watching() || drag !== 'off';
}

/** Takes noVNC's own gesture events before the canvas sees them: what
 *  moves the view stays here, the rest is input for the desktop. */
function onGesture(e) {
  const d = e.detail;
  const kind = d.type;
  if (kind === 'pinch') {
    pinchGesture(e.type, d);
  } else if (kind === 'twodrag' && (viewing() || zoom > 1.001)) {
    panGesture(e.type, d.magnitudeX, d.magnitudeY);
  } else if (kind === 'drag' && viewing()) {
    if (e.type === 'gesturestart') {
      cancelAnimationFrame(animation);
      gesture = { x: d.clientX, y: d.clientY, panX, panY };
    } else if (gesture) {
      panGesture(e.type, d.clientX - gesture.x, d.clientY - gesture.y);
    }
  } else if (kind === 'onetap' && drag !== 'off' && !watching()) {
    if (e.type === 'gesturestart') dragTap(d.clientX, d.clientY);
  } else if (kind === 'onetap' && watching()) {
    if (e.type === 'gesturestart') doubleTap(d.clientX, d.clientY);
  } else if (!viewing()) {
    return; // the mouse: noVNC sends it
  }
  e.stopPropagation();
}

function pinchGesture(type, d) {
  const distance = Math.hypot(d.magnitudeX, d.magnitudeY);
  if (type === 'gesturestart') {
    cancelAnimationFrame(animation);
    gesture = { distance: Math.max(distance, 1), cx: d.clientX, cy: d.clientY, zoom, panX, panY };
    return;
  }
  if (!gesture?.distance) return;
  const view = zoomAround(gesture.zoom * (distance / gesture.distance), gesture.cx, gesture.cy, gesture);
  if (type === 'gestureend') {
    moved();
    commit(...view);
    gesture = null;
  } else {
    preview(...view);
  }
}

function panGesture(type, dx, dy) {
  if (type === 'gesturestart') {
    cancelAnimationFrame(animation);
    gesture = { panX, panY };
    return;
  }
  if (!gesture) return;
  const view = clampView(zoom, gesture.panX + dx, gesture.panY + dy);
  if (type === 'gestureend') {
    moved();
    commit(...view);
    gesture = null;
  } else {
    preview(...view);
  }
}

function doubleTap(x, y) {
  const now = performance.now();
  const second = lastTap && now - lastTap.at < DOUBLE_TAP_MS &&
    Math.hypot(x - lastTap.x, y - lastTap.y) < DOUBLE_TAP_SLOP;
  lastTap = second ? null : { at: now, x, y };
  if (!second) return;
  if (!atHome) {
    const s = shown();
    goHome({ x: (s.x0 + s.x1) / 2, y: (s.y0 + s.y1) / 2 });
    return;
  }
  moved();
  animateTo(zoomAround(Math.max(homeZoom() * 2, DOUBLE_TAP_ZOOM), x, y));
}

// ------------------------------------------------------------ following

/** A change of the desktop at (x, y, w, h), in its pixels. */
function noteActivity(x, y, w, h) {
  const f = frameSize();
  if (w * h > MAX_ACTIVITY * f.w * f.h || y + h <= PANEL_ROWS) return;
  const next = { left: x, top: y, right: x + w, bottom: y + h };
  if (activity) {
    const union = {
      left: Math.min(activity.left, next.left),
      top: Math.min(activity.top, next.top),
      right: Math.max(activity.right, next.right),
      bottom: Math.max(activity.bottom, next.bottom),
    };
    // Two far changes in one beat: the latest is where to look.
    const area = (union.right - union.left) * (union.bottom - union.top);
    activity = area > MAX_ACTIVITY * f.w * f.h ? next : union;
  } else {
    activity = next;
  }
}

/** Each beat: the view moves to what changed, unless that already shows
 *  well inside it, or the person is moving the view or dragging. */
function followBeat() {
  const a = activity;
  activity = null;
  if (!a || !follow || gesture || animating || drag !== 'off' || zoom <= 1.001) return;
  const f = frameSize();
  const s = shown();
  const mx = (s.x1 - s.x0) * FOLLOW_MARGIN;
  const my = (s.y1 - s.y0) * FOLLOW_MARGIN;
  const ax0 = a.left / f.w;
  const ay0 = a.top / f.h;
  const ax1 = a.right / f.w;
  const ay1 = a.bottom / f.h;
  if (ax0 >= s.x0 + mx && ax1 <= s.x1 - mx && ay0 >= s.y0 + my && ay1 <= s.y1 - my) return;
  animateTo(centerOn(zoom, { x: (ax0 + ax1) / 2, y: (ay0 + ay1) / 2 }));
}

setInterval(followBeat, FOLLOW_BEAT_MS);

// ------------------------------------------------------------ drag

function setDrag(next) {
  if (next === drag) return;
  drag = next;
  post({ type: 'drag', state: drag });
}

/** The pointer to client (x, y) with [mask] held: noVNC's own path for a
 *  touch, which its API does not offer. */
function pointer(x, y, mask) {
  const canvas = stage.querySelector('canvas');
  if (!rfb || !canvas) return;
  const p = clientToElement(x, y, canvas);
  rfb._cursor.move(x, y);
  rfb._handleMouseButton(p.x, p.y, mask);
}

function share(x, y) {
  const r = stage.querySelector('canvas').getBoundingClientRect();
  return { x: (x - r.left) / r.width, y: (y - r.top) / r.height };
}

function unshare(p) {
  const r = stage.querySelector('canvas').getBoundingClientRect();
  return { x: r.left + p.x * r.width, y: r.top + p.y * r.height };
}

const wait = (ms) => new Promise((done) => setTimeout(done, ms));

async function dragTap(x, y) {
  if (drag === 'pick') {
    pointer(x, y, 0x1);
    held = share(x, y);
    setDrag('drop');
    return;
  }
  if (drag !== 'drop') return;
  // The view may have moved since the pick: the held point is where the
  // desktop shows it now.
  const from = unshare(held);
  const mine = generation;
  held = null;
  setDrag('off');
  for (let i = 1; i <= DROP_STEPS; i++) {
    const t = i / DROP_STEPS;
    pointer(from.x + (x - from.x) * t, from.y + (y - from.y) * t, 0x1);
    await wait(DROP_STEP_MS);
    if (mine !== generation) return;
  }
  await wait(DROP_SETTLE_MS);
  if (mine === generation) pointer(x, y, 0x0);
}

/** Drag ends without a drop: Escape cancels the desktop's drag, then the
 *  button lets go where it was held. */
function cancelDrag() {
  if (drag === 'drop' && held && rfb && !rfb.viewOnly) {
    sendKey(KEYS.escape);
    const at = unshare(held);
    pointer(at.x, at.y, 0x0);
  }
  held = null;
  setDrag('off');
}

for (const type of ['gesturestart', 'gesturemove', 'gestureend']) {
  stage.addEventListener(type, onGesture, true);
}
window.addEventListener('resize', relayout);

// ------------------------------------------------------------ the app's API

function sendKey([keysym, code], down) {
  rfb.sendKey(keysym, code, down);
}

/** Runs [send] with [mods] held down around it. */
function withModifiers(mods, send) {
  const held = (mods ?? []).map((m) => MODIFIERS[m]).filter(Boolean);
  held.forEach((m) => sendKey(m, true));
  send();
  held.reverse().forEach((m) => sendKey(m, false));
}

function closeStream(code) {
  held = null;
  setDrag('off');
  generation++;
  if (socket && socket.readyState <= WebSocket.OPEN) socket.close(code);
  try {
    rfb?.disconnect();
  } catch {
    // The client had closed itself already.
  }
  rfb = null;
  socket = null;
}

window.pomelu = {
  /** Where the app's chrome floats ([insets]), the accent and width (CSS
   *  px) of the control ring, and how long a view animation takes (0:
   *  reduced motion). */
  layout(next, accent, ring, motion) {
    insets = next;
    motionMs = motion;
    const style = document.documentElement.style;
    style.setProperty('--accent', accent);
    style.setProperty('--ring', `${ring}px`);
    style.setProperty('--motion', `${motion}ms`);
    relayout();
  },

  /** The latest still while the stream comes up; null hides it. */
  poster(dataUrl) {
    if (dataUrl) poster.src = dataUrl;
    poster.classList.toggle('shown', !!dataUrl);
  },

  /** Watches [url] (a single-use display ticket); input only without
   *  [viewOnly]. A stream still open closes with [keep], a code that keeps
   *  its control at the gateway. */
  attach(url, viewOnly, keep) {
    closeStream(keep);
    const mine = generation;
    const ws = new WebSocket(url);
    ws.binaryType = 'arraybuffer';
    let closeCode = 0;
    // Before noVNC's own handlers: the code is known when it reports.
    ws.addEventListener('close', (e) => { closeCode = e.code; });
    const client = new RFB(stage, ws, { shared: true });
    client.scaleViewport = true;
    client.resizeSession = false;
    client.focusOnClick = true;
    client.background = 'transparent';
    client.qualityLevel = 7;
    client.viewOnly = viewOnly;
    stage.classList.toggle('control', !viewOnly);
    // Every change noVNC draws is a place the bot may be working.
    const display = client._display;
    const damage = display._damage.bind(display);
    display._damage = (x, y, w, h) => {
      damage(x, y, w, h);
      noteActivity(x, y, w, h);
    };
    client.addEventListener('connect', () => {
      if (mine !== generation) return;
      poster.classList.remove('shown');
      relayout();
      post({ type: 'connect' });
    });
    client.addEventListener('disconnect', () => {
      if (mine !== generation) return;
      rfb = null;
      socket = null;
      post({ type: 'disconnect', code: closeCode });
    });
    rfb = client;
    socket = ws;
  },

  /** Ends the stream. 1000 hands control back at the gateway; any other
   *  code keeps it, for a viewer that comes back. */
  detach(code) {
    closeStream(code);
  },

  viewOnly(viewOnly) {
    if (viewOnly) {
      held = null;
      setDrag('off');
    }
    stage.classList.toggle('control', !viewOnly);
    if (!rfb) return;
    rfb.viewOnly = viewOnly;
    if (!viewOnly) rfb.focus();
  },

  /** What the keyboard typed: [back] backspaces, then [text]; a new line
   *  is Return. [mods] (`ctrl`, `alt`) are held around all of it. */
  type(back, text, mods) {
    if (watching()) return;
    withModifiers(mods, () => {
      for (let i = 0; i < back; i++) sendKey(KEYS.backspace);
      for (const ch of text) {
        if (ch === '\n') sendKey(KEYS.enter);
        else rfb.sendKey(keysyms.lookup(ch.codePointAt(0)));
      }
    });
  },

  /** [text] onto the desktop's clipboard, for its own Paste. */
  clipboard(text) {
    if (!watching()) rfb.clipboardPasteFrom(text);
  },

  /** One named key ([KEYS]) with [mods]. */
  press(name, mods) {
    if (watching() || !KEYS[name]) return;
    withModifiers(mods, () => sendKey(KEYS[name]));
  },

  /** Drag on (the next tap picks up) or off (a held pick is let go
   *  without a drop). */
  drag(on) {
    if (on && !watching() && drag === 'off') setDrag('pick');
    else if (!on) cancelDrag();
  },

  /** Back to the whole desktop; it stays whole. */
  fit() {
    moved();
    atHome = homeZoom() <= 1.001;
    animateTo(clampView(1, 0, 0));
  },

  /** The home view of a tall window: the desktop filling it, following
   *  what changes, around the middle of what shows now. */
  fill() {
    const s = shown();
    goHome({ x: (s.x0 + s.x1) / 2, y: (s.y0 + s.y1) / 2 });
  },
};

relayout();
post({ type: 'ready' });
