part of '../tokens.dart';

/// Content surfaces: solid fills and a hairline outline. Controls that
/// float above content use [GlassSpec].
@immutable
class SurfaceSpec {
  const SurfaceSpec({
    required this.surface,
    required this.surfaceElevated,
    required this.surfacePressed,
    required this.outline,
    required this.grouped,
    required this.groupedCell,
    required this.groupedElevated,
    required this.groupedCellElevated,
    required this.fieldFill,
    this.fieldEdges = false,
    this.borderWidth = 1,
    this.disabledOpacity = 0.5,
    this.pendingOpacity = 0.6,
  });

  /// Cards, rows, bubbles.
  final Color surface;

  /// Bars, sheets, menus above content.
  final Color surfaceElevated;

  /// Fill while a control is held down.
  final Color surfacePressed;

  /// Hairline dividers and card edges.
  final Color outline;

  /// A form page behind its cards (iOS `systemGroupedBackground`).
  final Color grouped;

  /// A form card on [grouped] (`secondarySystemGroupedBackground`).
  final Color groupedCell;

  /// [grouped] and [groupedCell] on a sheet, as iOS raises them there: in
  /// dark mode a step lighter, so the sheet stands off the dimmed page.
  final Color groupedElevated;
  final Color groupedCellElevated;

  /// A text field outside a form card: a gray fill, no outline, as iOS
  /// draws a search or sheet field (`tertiarySystemFill`).
  final Color fieldFill;

  /// Fields keep an outline (Increase Contrast).
  final bool fieldEdges;
  final double borderWidth;

  /// A control that cannot be used now.
  final double disabledOpacity;

  /// Content still on its way (a message being sent).
  final double pendingOpacity;

  factory SurfaceSpec.light() => const SurfaceSpec(
    surface: Color(0xFFF2F2F7),
    surfaceElevated: Color(0xFFFFFFFF),
    surfacePressed: Color(0xFFE5E5EA),
    outline: Color(0x1F000000),
    grouped: Color(0xFFF2F2F7),
    groupedCell: Color(0xFFFFFFFF),
    groupedElevated: Color(0xFFF2F2F7),
    groupedCellElevated: Color(0xFFFFFFFF),
    fieldFill: Color(0x1F767680),
  );

  factory SurfaceSpec.dark() => const SurfaceSpec(
    surface: Color(0xFF1C1C1E),
    surfaceElevated: Color(0xFF2C2C2E),
    surfacePressed: Color(0xFF3A3A3C),
    outline: Color(0x29FFFFFF),
    grouped: Color(0xFF000000),
    groupedCell: Color(0xFF1C1C1E),
    groupedElevated: Color(0xFF1C1C1E),
    groupedCellElevated: Color(0xFF2C2C2E),
    fieldFill: Color(0x3D767680),
  );

  /// The surfaces inside a sheet: its page and cards raised.
  SurfaceSpec get elevated =>
      _copy(grouped: groupedElevated, groupedCell: groupedCellElevated);

  /// Hairlines under Increase Contrast: as strong as a control's edge.
  SurfaceSpec increasedContrast(Color outline) =>
      _copy(outline: outline, fieldEdges: true);

  SurfaceSpec _copy({
    Color? outline,
    Color? grouped,
    Color? groupedCell,
    bool? fieldEdges,
  }) => SurfaceSpec(
    surface: surface,
    surfaceElevated: surfaceElevated,
    surfacePressed: surfacePressed,
    outline: outline ?? this.outline,
    grouped: grouped ?? this.grouped,
    groupedCell: groupedCell ?? this.groupedCell,
    groupedElevated: groupedElevated,
    groupedCellElevated: groupedCellElevated,
    fieldFill: fieldFill,
    fieldEdges: fieldEdges ?? this.fieldEdges,
    borderWidth: borderWidth,
    disabledOpacity: disabledOpacity,
    pendingOpacity: pendingOpacity,
  );

  static SurfaceSpec lerp(SurfaceSpec a, SurfaceSpec b, double t) =>
      SurfaceSpec(
        surface: Color.lerp(a.surface, b.surface, t)!,
        surfaceElevated: Color.lerp(a.surfaceElevated, b.surfaceElevated, t)!,
        surfacePressed: Color.lerp(a.surfacePressed, b.surfacePressed, t)!,
        outline: Color.lerp(a.outline, b.outline, t)!,
        grouped: Color.lerp(a.grouped, b.grouped, t)!,
        groupedCell: Color.lerp(a.groupedCell, b.groupedCell, t)!,
        groupedElevated: Color.lerp(a.groupedElevated, b.groupedElevated, t)!,
        groupedCellElevated: Color.lerp(
          a.groupedCellElevated,
          b.groupedCellElevated,
          t,
        )!,
        fieldFill: Color.lerp(a.fieldFill, b.fieldFill, t)!,
        fieldEdges: t < 0.5 ? a.fieldEdges : b.fieldEdges,
      );
}
