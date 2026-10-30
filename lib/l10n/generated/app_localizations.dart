import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Pomelu'**
  String get appName;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navBots.
  ///
  /// In en, this message translates to:
  /// **'Bots'**
  String get navBots;

  /// No description provided for @connStateConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connStateConnected;

  /// No description provided for @connStateConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get connStateConnecting;

  /// No description provided for @connStateReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting…'**
  String get connStateReconnecting;

  /// No description provided for @connStateDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get connStateDisconnected;

  /// No description provided for @connStateAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get connStateAuthRequired;

  /// No description provided for @connStateNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'No gateway'**
  String get connStateNotConfigured;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGatewaySection.
  ///
  /// In en, this message translates to:
  /// **'Remote gateway'**
  String get settingsGatewaySection;

  /// No description provided for @settingsGatewayUrl.
  ///
  /// In en, this message translates to:
  /// **'Gateway URL'**
  String get settingsGatewayUrl;

  /// No description provided for @settingsGatewayUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://hermes.example.com'**
  String get settingsGatewayUrlHint;

  /// No description provided for @settingsGatewayUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid http(s) URL'**
  String get settingsGatewayUrlInvalid;

  /// Warning under the URL field while the address is plain http:// to a host on the internet (not this phone, a local network or a tailnet).
  ///
  /// In en, this message translates to:
  /// **'Not encrypted. This address sends everything, your password and messages too, readable over the internet. Use https:// if the gateway has it.'**
  String get settingsNotEncrypted;

  /// No description provided for @settingsNotEncryptedConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Send the password unencrypted?'**
  String get settingsNotEncryptedConfirmTitle;

  /// No description provided for @settingsNotEncryptedConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This address is plain http:// over the internet. Anyone on the way can read the password, and use it.'**
  String get settingsNotEncryptedConfirmBody;

  /// No description provided for @settingsNotEncryptedConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get settingsNotEncryptedConfirmAction;

  /// Under the URL field when the gateway is older than this app supports. {version} is its version, {minimum} the oldest supported.
  ///
  /// In en, this message translates to:
  /// **'This gateway runs Hermes {version}. This app needs Hermes {minimum} or newer: update Hermes.'**
  String settingsGatewayTooOld(String version, String minimum);

  /// No description provided for @settingsAuthDetecting.
  ///
  /// In en, this message translates to:
  /// **'Detecting…'**
  String get settingsAuthDetecting;

  /// No description provided for @settingsAuthNone.
  ///
  /// In en, this message translates to:
  /// **'This gateway does not require sign-in'**
  String get settingsAuthNone;

  /// No description provided for @settingsAuthBasic.
  ///
  /// In en, this message translates to:
  /// **'Username and password'**
  String get settingsAuthBasic;

  /// No description provided for @settingsAuthToken.
  ///
  /// In en, this message translates to:
  /// **'Session token'**
  String get settingsAuthToken;

  /// Under the URL field when the gateway signs in with a provider this app has no form for. {provider} is the provider name or names.
  ///
  /// In en, this message translates to:
  /// **'This gateway uses {provider}, which this app cannot sign in with yet'**
  String settingsAuthUnsupported(String provider);

  /// No description provided for @settingsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get settingsUsername;

  /// No description provided for @settingsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get settingsPassword;

  /// No description provided for @settingsToken.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get settingsToken;

  /// No description provided for @settingsTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the dashboard session token'**
  String get settingsTokenHint;

  /// Heading over the username and password card in Settings.
  ///
  /// In en, this message translates to:
  /// **'Sign-in'**
  String get settingsSignInSection;

  /// No description provided for @settingsSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get settingsSignIn;

  /// No description provided for @settingsSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get settingsSigningIn;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// Status of the sign-in. {user} is the account name.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {user}'**
  String settingsSignedInAs(String user);

  /// No description provided for @settingsTestConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get settingsTestConnection;

  /// No description provided for @settingsTesting.
  ///
  /// In en, this message translates to:
  /// **'Testing…'**
  String get settingsTesting;

  /// Result of Test connection when both HTTP and the WebSocket work. {version} is the gateway version.
  ///
  /// In en, this message translates to:
  /// **'Reachable · gateway {version}'**
  String settingsTestOk(String version);

  /// Result of Test connection when the HTTP request failed. {reason} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'HTTP failed: {reason}'**
  String settingsTestHttpFail(String reason);

  /// Result of Test connection when HTTP works and the WebSocket does not. {reason} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'HTTP ok, WebSocket failed: {reason}'**
  String settingsTestWsFail(String reason);

  /// Result of Test connection when HTTP works and the WebSocket does not, with what the socket reported. {reason} is the failure sentence, {detail} a short technical note such as 'HTTP 403' or 'close 1011'.
  ///
  /// In en, this message translates to:
  /// **'HTTP ok, WebSocket failed: {reason} ({detail})'**
  String settingsTestWsFailDetail(String reason, String detail);

  /// No description provided for @settingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save and connect'**
  String get settingsSave;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open-source licenses'**
  String get settingsLicenses;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// Snack bar when no app could open a web page (the privacy policy).
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get settingsLinkFailed;

  /// Row title in About; the gateway's version is its value.
  ///
  /// In en, this message translates to:
  /// **'Gateway'**
  String get settingsGatewayLabel;

  /// Line between two conversations with the same bot: the one below started fresh.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get chatNewConversation;

  /// No description provided for @sidebarNoBots.
  ///
  /// In en, this message translates to:
  /// **'No bots found on this gateway'**
  String get sidebarNoBots;

  /// No description provided for @sidebarRunning.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get sidebarRunning;

  /// Hint in the empty message field. {bot} is the bot name.
  ///
  /// In en, this message translates to:
  /// **'Message {bot}'**
  String chatPlaceholder(String bot);

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get chatStop;

  /// No description provided for @chatAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get chatAttach;

  /// No description provided for @chatRecord.
  ///
  /// In en, this message translates to:
  /// **'Hold to record'**
  String get chatRecord;

  /// No description provided for @chatRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording… release to send, slide back to cancel'**
  String get chatRecording;

  /// No description provided for @chatTranscribing.
  ///
  /// In en, this message translates to:
  /// **'Turning speech into text…'**
  String get chatTranscribing;

  /// No description provided for @chatVoiceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No speech heard'**
  String get chatVoiceEmpty;

  /// No description provided for @chatVoiceFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not turn the recording into text'**
  String get chatVoiceFailed;

  /// No description provided for @chatThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking'**
  String get chatThinking;

  /// Line of the agent's plan above the composer. {done} of {total} steps are finished.
  ///
  /// In en, this message translates to:
  /// **'Plan · {done} of {total}'**
  String chatPlanProgress(int done, int total);

  /// No description provided for @chatPlanDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get chatPlanDone;

  /// No description provided for @chatPlanWorking.
  ///
  /// In en, this message translates to:
  /// **'Working on'**
  String get chatPlanWorking;

  /// No description provided for @chatPlanCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get chatPlanCancelled;

  /// No description provided for @chatPlanToDo.
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get chatPlanToDo;

  /// Tool row while the tool runs. {tool} is the tool name.
  ///
  /// In en, this message translates to:
  /// **'Running {tool}'**
  String chatToolRunning(String tool);

  /// Tool row when the tool is done. {tool} is the tool name.
  ///
  /// In en, this message translates to:
  /// **'{tool}'**
  String chatToolDone(String tool);

  /// Tool row when the tool failed. {tool} is the tool name.
  ///
  /// In en, this message translates to:
  /// **'{tool} failed'**
  String chatToolFailed(String tool);

  /// Header of a group of tools while one runs. {tool} is the running tool, {count} the tools in the group.
  ///
  /// In en, this message translates to:
  /// **'Running {tool} · {count} tools'**
  String chatToolsRunning(String tool, int count);

  /// Header of a finished group of tools. {count} is the number of tools.
  ///
  /// In en, this message translates to:
  /// **'{count} tools'**
  String chatToolsDone(int count);

  /// Header of a finished group of tools when some failed. {count} is all the tools, {failed} the ones that failed.
  ///
  /// In en, this message translates to:
  /// **'{count} tools · {failed} failed'**
  String chatToolsFailed(int count, int failed);

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chatCopied;

  /// No description provided for @chatLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'This link cannot open from a chat. It was copied.'**
  String get chatLinkCopied;

  /// No description provided for @chatCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get chatCopy;

  /// No description provided for @chatFailedToSend.
  ///
  /// In en, this message translates to:
  /// **'Not sent · tap to retry'**
  String get chatFailedToSend;

  /// Greeting in an empty chat. {bot} is the bot name.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {bot}'**
  String chatEmptyTitle(String bot);

  /// No description provided for @chatEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Messages stream live from your gateway.'**
  String get chatEmptyBody;

  /// No description provided for @chatSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a bot'**
  String get chatSelectTitle;

  /// No description provided for @chatSelectBody.
  ///
  /// In en, this message translates to:
  /// **'Open the menu to choose where to start.'**
  String get chatSelectBody;

  /// No description provided for @chatScrollToBottom.
  ///
  /// In en, this message translates to:
  /// **'Jump to latest'**
  String get chatScrollToBottom;

  /// Row under a turn the bot could not finish. {message} is the reason the gateway gave.
  ///
  /// In en, this message translates to:
  /// **'The bot hit an error: {message}'**
  String chatErrorTurn(String message);

  /// No description provided for @chatCopyMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Copy as Markdown'**
  String get chatCopyMarkdown;

  /// No description provided for @chatQuoteReply.
  ///
  /// In en, this message translates to:
  /// **'Quote reply'**
  String get chatQuoteReply;

  /// No description provided for @chatResend.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get chatResend;

  /// No description provided for @chatEditResend.
  ///
  /// In en, this message translates to:
  /// **'Edit and resend'**
  String get chatEditResend;

  /// No description provided for @chatEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get chatEditMessage;

  /// No description provided for @chatDiscarded.
  ///
  /// In en, this message translates to:
  /// **'Discarded'**
  String get chatDiscarded;

  /// No description provided for @chatAlreadySending.
  ///
  /// In en, this message translates to:
  /// **'This message is already on its way'**
  String get chatAlreadySending;

  /// No description provided for @chatQueueFull.
  ///
  /// In en, this message translates to:
  /// **'Too many messages are waiting to be sent. Send or discard some first.'**
  String get chatQueueFull;

  /// No description provided for @chatHide.
  ///
  /// In en, this message translates to:
  /// **'Hide on this phone'**
  String get chatHide;

  /// No description provided for @chatReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReport;

  /// No description provided for @chatReportHint.
  ///
  /// In en, this message translates to:
  /// **'Opens an email of this reply to Royan AB, the app\'s developer'**
  String get chatReportHint;

  /// No description provided for @chatReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Why report this reply?'**
  String get chatReportTitle;

  /// No description provided for @chatReportHarmful.
  ///
  /// In en, this message translates to:
  /// **'Harmful or dangerous'**
  String get chatReportHarmful;

  /// No description provided for @chatReportHateful.
  ///
  /// In en, this message translates to:
  /// **'Hateful or harassing'**
  String get chatReportHateful;

  /// No description provided for @chatReportSexual.
  ///
  /// In en, this message translates to:
  /// **'Sexual content'**
  String get chatReportSexual;

  /// No description provided for @chatReportMisleading.
  ///
  /// In en, this message translates to:
  /// **'False or misleading'**
  String get chatReportMisleading;

  /// No description provided for @chatReportOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get chatReportOther;

  /// Shown when no mail app takes a reply report. {email} is the developer's address.
  ///
  /// In en, this message translates to:
  /// **'No mail app found. Write to {email}.'**
  String chatReportFailed(String email);

  /// No description provided for @chatHideHint.
  ///
  /// In en, this message translates to:
  /// **'Only hides it here. The bot still remembers it.'**
  String get chatHideHint;

  /// No description provided for @chatHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden on this phone'**
  String get chatHidden;

  /// No description provided for @chatUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get chatUndo;

  /// No description provided for @chatShowHidden.
  ///
  /// In en, this message translates to:
  /// **'Show hidden messages'**
  String get chatShowHidden;

  /// Row that stands for messages the user hid on this phone. {count} is how many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hidden message} other{{count} hidden messages}}'**
  String chatHiddenCount(int count);

  /// No description provided for @chatDeleteFrom.
  ///
  /// In en, this message translates to:
  /// **'Delete from here'**
  String get chatDeleteFrom;

  /// No description provided for @chatDeleteFromHint.
  ///
  /// In en, this message translates to:
  /// **'Removes this exchange and everything after it'**
  String get chatDeleteFromHint;

  /// No description provided for @chatDeleteFromTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete from here?'**
  String get chatDeleteFromTitle;

  /// Body of the confirmation before a message and all the later ones are deleted. {count} is how many later exchanges go too.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{The bot will forget this exchange. This cannot be undone.} =1{The bot will forget this exchange and 1 later one. This cannot be undone.} other{The bot will forget this exchange and {count} later ones. This cannot be undone.}}'**
  String chatDeleteFromBody(int count);

  /// No description provided for @chatDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatDeleteAction;

  /// No description provided for @chatDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get chatDeleted;

  /// No description provided for @chatDeleteBusy.
  ///
  /// In en, this message translates to:
  /// **'Wait for the bot to finish first'**
  String get chatDeleteBusy;

  /// No description provided for @chatDeleteUnsaved.
  ///
  /// In en, this message translates to:
  /// **'Not saved yet. Try again in a moment.'**
  String get chatDeleteUnsaved;

  /// No description provided for @chatDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete'**
  String get chatDeleteFailed;

  /// Status under the composer while messages wait for the connection. {count} is how many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message waiting to send} other{{count} messages waiting to send}}'**
  String chatQueuedNotice(int count);

  /// Status under the composer when messages could not be sent. {count} is how many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message was not sent} other{{count} messages were not sent}}'**
  String chatFailedNotice(int count);

  /// No description provided for @chatOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Offline · messages send when the gateway is back'**
  String get chatOfflineNotice;

  /// Status under the composer while files upload. {name} is the file, {done} of {total} files are sent.
  ///
  /// In en, this message translates to:
  /// **'Uploading {name} ({done}/{total})'**
  String chatUploadProgress(String name, int done, int total);

  /// Snack bar when the files of one message are too large together. {limit} is the size limit, formatted.
  ///
  /// In en, this message translates to:
  /// **'These attachments total more than {limit}'**
  String attachBatchTooLarge(String limit);

  /// No description provided for @chatImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get chatImageFailed;

  /// No description provided for @chatImageLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading image…'**
  String get chatImageLoading;

  /// No description provided for @attachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo library'**
  String get attachPhoto;

  /// No description provided for @attachCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get attachCamera;

  /// No description provided for @attachVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get attachVideo;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get attachFile;

  /// No description provided for @attachLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get attachLocation;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get locationTitle;

  /// No description provided for @locationShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get locationShare;

  /// No description provided for @locationMine.
  ///
  /// In en, this message translates to:
  /// **'My location'**
  String get locationMine;

  /// No description provided for @locationResolving.
  ///
  /// In en, this message translates to:
  /// **'Finding the address…'**
  String get locationResolving;

  /// No description provided for @locationNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address for this place'**
  String get locationNoAddress;

  /// No description provided for @locationOff.
  ///
  /// In en, this message translates to:
  /// **'Your location is not available. Move the map to the place.'**
  String get locationOff;

  /// No description provided for @locationTilesFailed.
  ///
  /// In en, this message translates to:
  /// **'The map could not load. Check the connection; the pin still works.'**
  String get locationTilesFailed;

  /// Text a shared location puts in the message field, over several lines. {address} is the street address; the coordinates are decimal degrees.
  ///
  /// In en, this message translates to:
  /// **'Location: {address}\nLatitude: {latitude}\nLongitude: {longitude}'**
  String locationMessage(String address, String latitude, String longitude);

  /// Text a shared location puts in the message field when no address was found. The coordinates are decimal degrees.
  ///
  /// In en, this message translates to:
  /// **'Location\nLatitude: {latitude}\nLongitude: {longitude}'**
  String locationMessageNoAddress(String latitude, String longitude);

  /// Snack bar when one file is over its size limit. {name} is the file, {limit} the size limit, formatted.
  ///
  /// In en, this message translates to:
  /// **'{name} is larger than {limit}'**
  String attachTooLarge(String name, String limit);

  /// No description provided for @attachRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get attachRemove;

  /// No description provided for @attachShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get attachShare;

  /// No description provided for @attachOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get attachOpen;

  /// No description provided for @attachSaveToFiles.
  ///
  /// In en, this message translates to:
  /// **'Save to Files'**
  String get attachSaveToFiles;

  /// Snack bar after a file from the bot was saved to a folder the user chose. {name} is the file name.
  ///
  /// In en, this message translates to:
  /// **'Saved {name}'**
  String attachSaved(String name);

  /// Snack bar when a file from the bot could not be saved. {name} is the file name.
  ///
  /// In en, this message translates to:
  /// **'Could not save {name}'**
  String attachSaveFailed(String name);

  /// Tooltip and screen-reader label of the menu button on a file from the bot. {name} is the file name.
  ///
  /// In en, this message translates to:
  /// **'Actions for {name}'**
  String attachFileActions(String name);

  /// Snack bar when the system has no app for a downloaded file.
  ///
  /// In en, this message translates to:
  /// **'No app on this phone can open {name}'**
  String attachNoApp(String name);

  /// No description provided for @attachPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not add the file. Check that the app may use the camera or files.'**
  String get attachPickFailed;

  /// Snack bar when a file could not be downloaded. {name} is the file name.
  ///
  /// In en, this message translates to:
  /// **'Could not download {name}'**
  String attachDownloadFailed(String name);

  /// No description provided for @attachVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get attachVoiceNote;

  /// No description provided for @attachMicDenied.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to record'**
  String get attachMicDenied;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get shareTitle;

  /// Subtitle of the share screen. {count} is the number of files and texts shared.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String shareItems(int count);

  /// No description provided for @shareNoGateway.
  ///
  /// In en, this message translates to:
  /// **'Set up a gateway first'**
  String get shareNoGateway;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the gateway'**
  String get errorNetwork;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'This account is not allowed'**
  String get errorForbidden;

  /// No description provided for @errorHostRefused.
  ///
  /// In en, this message translates to:
  /// **'The gateway refused this address. Use the address the gateway is set up for (its host name and port).'**
  String get errorHostRefused;

  /// No description provided for @errorNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Not supported by this gateway version'**
  String get errorNotSupported;

  /// Failure sentence when the gateway is older than this app supports. {version} is its version, {minimum} the oldest supported.
  ///
  /// In en, this message translates to:
  /// **'This gateway runs Hermes {version}; this app needs {minimum} or newer. Update Hermes.'**
  String errorGatewayTooOld(String version, String minimum);

  /// The gateway refused a message because another Hermes process has this chat open.
  ///
  /// In en, this message translates to:
  /// **'This chat is open in another Hermes window or terminal. Use it there, or start a new conversation here with /new.'**
  String get errorChatOpenElsewhere;

  /// The gateway refused a message because it reached its limit of open chats.
  ///
  /// In en, this message translates to:
  /// **'The gateway has as many chats open as it allows. Close one, then try again.'**
  String get errorGatewayFull;

  /// No description provided for @errorProtocol.
  ///
  /// In en, this message translates to:
  /// **'The gateway sent something this app did not understand'**
  String get errorProtocol;

  /// Failure sentence for an error the gateway reported. {message} is its own text.
  ///
  /// In en, this message translates to:
  /// **'Gateway error: {message}'**
  String errorServer(String message);

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorUnknown;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get actionDiscard;

  /// No description provided for @actionOpenMenu.
  ///
  /// In en, this message translates to:
  /// **'Open menu'**
  String get actionOpenMenu;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard your changes?'**
  String get discardTitle;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get actionOpenSettings;

  /// No description provided for @timeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get timeNow;

  /// Short age of a chat: minutes. {n} is the number.
  ///
  /// In en, this message translates to:
  /// **'{n}m'**
  String timeMinutes(int n);

  /// Short age of a chat: hours. {n} is the number.
  ///
  /// In en, this message translates to:
  /// **'{n}h'**
  String timeHours(int n);

  /// Day separator above the first message sent today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get timeToday;

  /// No description provided for @timeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeYesterday;

  /// No description provided for @timeTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get timeTomorrow;

  /// No description provided for @chatDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get chatDismiss;

  /// No description provided for @chatShare.
  ///
  /// In en, this message translates to:
  /// **'Share message'**
  String get chatShare;

  /// No description provided for @chatReadAloud.
  ///
  /// In en, this message translates to:
  /// **'Read aloud'**
  String get chatReadAloud;

  /// No description provided for @chatStopReading.
  ///
  /// In en, this message translates to:
  /// **'Stop reading'**
  String get chatStopReading;

  /// No description provided for @chatReadingAloud.
  ///
  /// In en, this message translates to:
  /// **'Reading aloud in the bot\'s voice…'**
  String get chatReadingAloud;

  /// No description provided for @chatToolOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get chatToolOutput;

  /// No description provided for @chatApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval needed'**
  String get chatApprovalTitle;

  /// No description provided for @chatChoiceOnce.
  ///
  /// In en, this message translates to:
  /// **'Allow once'**
  String get chatChoiceOnce;

  /// No description provided for @chatChoiceAlways.
  ///
  /// In en, this message translates to:
  /// **'Always allow'**
  String get chatChoiceAlways;

  /// No description provided for @chatChoiceSession.
  ///
  /// In en, this message translates to:
  /// **'Allow for this chat'**
  String get chatChoiceSession;

  /// No description provided for @chatChoiceDeny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get chatChoiceDeny;

  /// No description provided for @chatApprovalRisky.
  ///
  /// In en, this message translates to:
  /// **'The security scan flagged this command as risky.'**
  String get chatApprovalRisky;

  /// No description provided for @chatClarifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get chatClarifyTitle;

  /// No description provided for @chatClarifyHint.
  ///
  /// In en, this message translates to:
  /// **'Type your answer'**
  String get chatClarifyHint;

  /// No description provided for @chatClarifyOther.
  ///
  /// In en, this message translates to:
  /// **'Other answer'**
  String get chatClarifyOther;

  /// No description provided for @chatClarifyRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get chatClarifyRecommended;

  /// Step counter over the questions of a clarify request.
  ///
  /// In en, this message translates to:
  /// **'Question {number} of {total}'**
  String chatClarifyStep(int number, int total);

  /// No description provided for @chatRequestSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get chatRequestSkip;

  /// No description provided for @chatRequestSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatRequestSend;

  /// No description provided for @chatInputSudoTitle.
  ///
  /// In en, this message translates to:
  /// **'Password needed'**
  String get chatInputSudoTitle;

  /// No description provided for @chatInputSecretTitle.
  ///
  /// In en, this message translates to:
  /// **'Secret needed'**
  String get chatInputSecretTitle;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the value'**
  String get chatInputHint;

  /// No description provided for @chatInputShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get chatInputShow;

  /// No description provided for @chatInputHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get chatInputHide;

  /// Snack bar when more files are added than one message takes. {count} is the limit.
  ///
  /// In en, this message translates to:
  /// **'You can attach at most {count} files'**
  String attachTooMany(int count);

  /// No description provided for @mediaPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get mediaPlay;

  /// No description provided for @mediaPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get mediaPause;

  /// No description provided for @sidebarRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get sidebarRefresh;

  /// No description provided for @sidebarLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load bots'**
  String get sidebarLoadFailed;

  /// No description provided for @sidebarNoBotsBody.
  ///
  /// In en, this message translates to:
  /// **'This gateway has no visible bots yet.'**
  String get sidebarNoBotsBody;

  /// No description provided for @shellNoGatewayBody.
  ///
  /// In en, this message translates to:
  /// **'Connect the app to your gateway to start chatting.'**
  String get shellNoGatewayBody;

  /// No description provided for @shareEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to send'**
  String get shareEmpty;

  /// No description provided for @shareEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Share a file or some text from another app to start.'**
  String get shareEmptyBody;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAboutSection;

  /// No description provided for @sidebarCollapseMenu.
  ///
  /// In en, this message translates to:
  /// **'Collapse menu'**
  String get sidebarCollapseMenu;

  /// No description provided for @sidebarExpandMenu.
  ///
  /// In en, this message translates to:
  /// **'Expand menu'**
  String get sidebarExpandMenu;

  /// No description provided for @composerModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get composerModel;

  /// No description provided for @composerEffort.
  ///
  /// In en, this message translates to:
  /// **'Effort'**
  String get composerEffort;

  /// No description provided for @composerEffortAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get composerEffortAuto;

  /// No description provided for @composerPickEffort.
  ///
  /// In en, this message translates to:
  /// **'Reasoning effort'**
  String get composerPickEffort;

  /// No description provided for @composerEffortNone.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get composerEffortNone;

  /// No description provided for @composerEffortMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get composerEffortMinimal;

  /// No description provided for @composerEffortLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get composerEffortLow;

  /// No description provided for @composerEffortMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get composerEffortMedium;

  /// No description provided for @composerEffortHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get composerEffortHigh;

  /// No description provided for @composerEffortXhigh.
  ///
  /// In en, this message translates to:
  /// **'Extra high'**
  String get composerEffortXhigh;

  /// No description provided for @composerEffortMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get composerEffortMax;

  /// No description provided for @composerEffortUltra.
  ///
  /// In en, this message translates to:
  /// **'Ultra'**
  String get composerEffortUltra;

  /// No description provided for @composerNoModels.
  ///
  /// In en, this message translates to:
  /// **'No models available'**
  String get composerNoModels;

  /// No description provided for @composerSearchModels.
  ///
  /// In en, this message translates to:
  /// **'Search models'**
  String get composerSearchModels;

  /// No description provided for @composerNoModelMatch.
  ///
  /// In en, this message translates to:
  /// **'No models match'**
  String get composerNoModelMatch;

  /// No description provided for @slashNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No matching command'**
  String get slashNoMatch;

  /// No description provided for @slashDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get slashDone;

  /// No description provided for @slashRunning.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get slashRunning;

  /// No description provided for @slashFailed.
  ///
  /// In en, this message translates to:
  /// **'Command failed'**
  String get slashFailed;

  /// No description provided for @slashNotReady.
  ///
  /// In en, this message translates to:
  /// **'The chat is not connected yet. Try the command again in a moment.'**
  String get slashNotReady;

  /// No description provided for @slashNewDesc.
  ///
  /// In en, this message translates to:
  /// **'Start a fresh conversation. The old one stays above.'**
  String get slashNewDesc;

  /// No description provided for @slashRestartDesc.
  ///
  /// In en, this message translates to:
  /// **'Restart the gateway.'**
  String get slashRestartDesc;

  /// No description provided for @slashUpdateDesc.
  ///
  /// In en, this message translates to:
  /// **'Update the gateway to the latest version.'**
  String get slashUpdateDesc;

  /// No description provided for @slashCompactDesc.
  ///
  /// In en, this message translates to:
  /// **'Summarize older turns to free up context.'**
  String get slashCompactDesc;

  /// No description provided for @slashRestartConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart the gateway?'**
  String get slashRestartConfirmTitle;

  /// No description provided for @slashRestartConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Every bot pauses for a moment. Running tasks finish first.'**
  String get slashRestartConfirmBody;

  /// No description provided for @slashRestartConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get slashRestartConfirmAction;

  /// No description provided for @slashUpdateConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Update the gateway?'**
  String get slashUpdateConfirmTitle;

  /// No description provided for @slashUpdateConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Installs the latest version and restarts the gateway. The app reconnects by itself.'**
  String get slashUpdateConfirmBody;

  /// No description provided for @slashUpdateConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get slashUpdateConfirmAction;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notify me'**
  String get settingsNotificationsEnabled;

  /// No description provided for @settingsNotificationsEnabledBody.
  ///
  /// In en, this message translates to:
  /// **'Notices from the bot and finished background tasks'**
  String get settingsNotificationsEnabledBody;

  /// No description provided for @settingsNotificationsPushOn.
  ///
  /// In en, this message translates to:
  /// **'Bots reach you by push, also while the app is closed'**
  String get settingsNotificationsPushOn;

  /// No description provided for @settingsNotificationsPushMissing.
  ///
  /// In en, this message translates to:
  /// **'To get bot messages while the app is closed, add the Pomelu plugin to Hermes (How to connect, step 6)'**
  String get settingsNotificationsPushMissing;

  /// No description provided for @settingsNotificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Blocked in system settings'**
  String get settingsNotificationsDenied;

  /// No description provided for @settingsKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Stay connected in the background'**
  String get settingsKeepAlive;

  /// No description provided for @settingsKeepAliveBody.
  ///
  /// In en, this message translates to:
  /// **'Keeps the gateway connection alive with the screen off. Shows a quiet ongoing notification.'**
  String get settingsKeepAliveBody;

  /// Title of the ongoing notification while the app stays connected in the background. Same words as the Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get notificationServiceTitle;

  /// No description provided for @notificationServiceBody.
  ///
  /// In en, this message translates to:
  /// **'Connected to your gateway'**
  String get notificationServiceBody;

  /// Ongoing notification text after the gateway could not be reached in the background for some minutes: the app stopped trying, to save battery, and tries again when opened or when the network changes.
  ///
  /// In en, this message translates to:
  /// **'Gateway unreachable. Paused until you open the app.'**
  String get notificationServiceParkedBody;

  /// No description provided for @notificationNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent'**
  String get notificationNoticeTitle;

  /// No description provided for @notificationWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent · warning'**
  String get notificationWarningTitle;

  /// No description provided for @notificationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent · error'**
  String get notificationErrorTitle;

  /// No description provided for @notificationBackgroundTitle.
  ///
  /// In en, this message translates to:
  /// **'Background task finished'**
  String get notificationBackgroundTitle;

  /// No description provided for @notificationBackgroundFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Background task failed'**
  String get notificationBackgroundFailedTitle;

  /// No description provided for @notificationQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent has a question'**
  String get notificationQuestionTitle;

  /// No description provided for @notificationApprovalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent needs your approval'**
  String get notificationApprovalTitle;

  /// No description provided for @notificationInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Your agent needs a value'**
  String get notificationInputTitle;

  /// No description provided for @notificationChannelAlerts.
  ///
  /// In en, this message translates to:
  /// **'Bot activity'**
  String get notificationChannelAlerts;

  /// No description provided for @notificationChannelAlertsBody.
  ///
  /// In en, this message translates to:
  /// **'Notices from the bots and finished background tasks.'**
  String get notificationChannelAlertsBody;

  /// No description provided for @notificationMessageAttachment.
  ///
  /// In en, this message translates to:
  /// **'Sent a file'**
  String get notificationMessageAttachment;

  /// No description provided for @notificationChannelMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get notificationChannelMessages;

  /// No description provided for @notificationChannelMessagesBody.
  ///
  /// In en, this message translates to:
  /// **'What your bots write while the app is closed.'**
  String get notificationChannelMessagesBody;

  /// No description provided for @notificationChannelConnection.
  ///
  /// In en, this message translates to:
  /// **'Gateway connection'**
  String get notificationChannelConnection;

  /// No description provided for @notificationChannelConnectionBody.
  ///
  /// In en, this message translates to:
  /// **'Keeps the connection to your gateway open while the app is in the background.'**
  String get notificationChannelConnectionBody;

  /// No description provided for @chatDetailsSummary.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get chatDetailsSummary;

  /// No description provided for @chatLinkYouTube.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get chatLinkYouTube;

  /// No description provided for @chatOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Open image'**
  String get chatOpenImage;

  /// Label on the jump-to-latest button. {count} is how many messages arrived below.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new message} other{{count} new messages}}'**
  String chatNewMessages(int count);

  /// No description provided for @chatSearchOpen.
  ///
  /// In en, this message translates to:
  /// **'Find in conversation'**
  String get chatSearchOpen;

  /// No description provided for @chatSearchClose.
  ///
  /// In en, this message translates to:
  /// **'Close search'**
  String get chatSearchClose;

  /// No description provided for @chatSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Find in conversation'**
  String get chatSearchHint;

  /// No description provided for @chatSearchNext.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get chatSearchNext;

  /// No description provided for @chatSearchPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous match'**
  String get chatSearchPrevious;

  /// No description provided for @chatSearchNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get chatSearchNoMatches;

  /// Position of the active match in the find bar.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String chatSearchProgress(int current, int total);

  /// No description provided for @botDetailsAction.
  ///
  /// In en, this message translates to:
  /// **'Bot details'**
  String get botDetailsAction;

  /// No description provided for @botDetailsSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get botDetailsSkills;

  /// No description provided for @botDetailsTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get botDetailsTools;

  /// No description provided for @botDetailsNoSkills.
  ///
  /// In en, this message translates to:
  /// **'No skills turned on'**
  String get botDetailsNoSkills;

  /// No description provided for @botDetailsNoSkillsBody.
  ///
  /// In en, this message translates to:
  /// **'This bot has no skills it can use.'**
  String get botDetailsNoSkillsBody;

  /// No description provided for @botDetailsNoTools.
  ///
  /// In en, this message translates to:
  /// **'No tools turned on'**
  String get botDetailsNoTools;

  /// No description provided for @botDetailsNoToolsBody.
  ///
  /// In en, this message translates to:
  /// **'This bot has no tools it can use.'**
  String get botDetailsNoToolsBody;

  /// No description provided for @botDetailsOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get botDetailsOther;

  /// No description provided for @botDetailsInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get botDetailsInstructions;

  /// No description provided for @botSoulEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get botSoulEdit;

  /// No description provided for @botSoulEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No instructions yet'**
  String get botSoulEmptyTitle;

  /// No description provided for @botSoulEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'This bot has no instructions file. It uses its default identity.'**
  String get botSoulEmptyBody;

  /// No description provided for @botSoulWrite.
  ///
  /// In en, this message translates to:
  /// **'Write instructions'**
  String get botSoulWrite;

  /// No description provided for @botSoulEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit instructions'**
  String get botSoulEditorTitle;

  /// No description provided for @botSoulEditorHint.
  ///
  /// In en, this message translates to:
  /// **'Describe who this bot is and how it works.'**
  String get botSoulEditorHint;

  /// No description provided for @botSoulSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get botSoulSave;

  /// No description provided for @botSoulSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved. A new session uses it.'**
  String get botSoulSaved;

  /// Error under the instructions editor. {message} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {message}'**
  String botSoulSaveFailed(String message);

  /// No description provided for @botSoulChangedTitle.
  ///
  /// In en, this message translates to:
  /// **'Changed on the gateway'**
  String get botSoulChangedTitle;

  /// No description provided for @botSoulChangedBody.
  ///
  /// In en, this message translates to:
  /// **'These instructions changed while you were editing. Saving replaces that version with yours.'**
  String get botSoulChangedBody;

  /// No description provided for @botSoulReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get botSoulReplace;

  /// No description provided for @botSoulDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'What you wrote is not saved.'**
  String get botSoulDiscardBody;

  /// No description provided for @botSoulEmptyConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Save empty instructions?'**
  String get botSoulEmptyConfirmTitle;

  /// No description provided for @botSoulEmptyConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This bot will use its default identity.'**
  String get botSoulEmptyConfirmBody;

  /// No description provided for @botSoulSaveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Save empty'**
  String get botSoulSaveEmpty;

  /// No description provided for @botDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get botDetailsLoadFailed;

  /// No description provided for @botDetailsCron.
  ///
  /// In en, this message translates to:
  /// **'Cron'**
  String get botDetailsCron;

  /// No description provided for @botCronEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No scheduled jobs'**
  String get botCronEmptyTitle;

  /// No description provided for @botCronEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'This bot has nothing scheduled.'**
  String get botCronEmptyBody;

  /// Schedule that repeats every few minutes. {count} is the interval.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every minute} other{Every {count} minutes}}'**
  String botCronEveryMinutes(int count);

  /// Schedule that repeats every few hours. {count} is the interval.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every hour} other{Every {count} hours}}'**
  String botCronEveryHours(int count);

  /// Schedule that repeats every few days. {count} is the interval.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every day} other{Every {count} days}}'**
  String botCronEveryDays(int count);

  /// Schedule that runs once a day. {time} is the time of day.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String botCronDaily(String time);

  /// Schedule that runs on some days of the week. {days} is a day or a range of days, {time} the time of day.
  ///
  /// In en, this message translates to:
  /// **'{days} at {time}'**
  String botCronWeekly(String days, String time);

  /// A daily or weekly schedule whose time is the gateway's clock, not the phone's (the job has no next run to convert it by). {schedule} is like 'Daily at 06:30'.
  ///
  /// In en, this message translates to:
  /// **'{schedule}, gateway time'**
  String botCronGatewayClock(String schedule);

  /// Schedule that runs once. {when} is the date and time.
  ///
  /// In en, this message translates to:
  /// **'Once, {when}'**
  String botCronOnce(String when);

  /// A date with a time. {day} is Today, Tomorrow or a date, {time} the time of day.
  ///
  /// In en, this message translates to:
  /// **'{day}, {time}'**
  String botCronWhen(String day, String time);

  /// When a job runs next. {when} is the date and time.
  ///
  /// In en, this message translates to:
  /// **'Next: {when}'**
  String botCronNext(String when);

  /// No description provided for @botCronPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get botCronPaused;

  /// No description provided for @botCronCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get botCronCompleted;

  /// No description provided for @botCronNeverRan.
  ///
  /// In en, this message translates to:
  /// **'Not run yet'**
  String get botCronNeverRan;

  /// When a job ran last and how it ended. {when} is the date and time, {status} the result.
  ///
  /// In en, this message translates to:
  /// **'Last run: {when} · {status}'**
  String botCronLastRun(String when, String status);

  /// No description provided for @botCronStatusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get botCronStatusOk;

  /// No description provided for @botCronDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this job?'**
  String get botCronDeleteTitle;

  /// Body of the confirmation before a scheduled job is deleted. {name} is the job name.
  ///
  /// In en, this message translates to:
  /// **'{name} stops running. You cannot undo this.'**
  String botCronDeleteBody(String name);

  /// No description provided for @botCronDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get botCronDelete;

  /// No description provided for @mediaSave.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get mediaSave;

  /// No description provided for @mediaSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get mediaSaved;

  /// No description provided for @mediaSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save image'**
  String get mediaSaveFailed;

  /// Spoken label of the context meter in the chat header. {percent} is how much of the window is used.
  ///
  /// In en, this message translates to:
  /// **'Context window, {percent} percent used'**
  String contextMeterUsed(int percent);

  /// No description provided for @contextMeterUnknown.
  ///
  /// In en, this message translates to:
  /// **'Context usage unavailable'**
  String get contextMeterUnknown;

  /// No description provided for @contextMeterTitle.
  ///
  /// In en, this message translates to:
  /// **'Context usage'**
  String get contextMeterTitle;

  /// No description provided for @contextMeterInput.
  ///
  /// In en, this message translates to:
  /// **'Input tokens'**
  String get contextMeterInput;

  /// No description provided for @contextMeterOutput.
  ///
  /// In en, this message translates to:
  /// **'Output tokens'**
  String get contextMeterOutput;

  /// No description provided for @contextMeterCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get contextMeterCompact;

  /// No description provided for @contextMeterCompactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Compact now'**
  String get contextMeterCompactConfirm;

  /// No description provided for @contextMeterCompactExplainer.
  ///
  /// In en, this message translates to:
  /// **'Summarizes older turns so the conversation fits back inside the context window. This cannot be undone.'**
  String get contextMeterCompactExplainer;

  /// Error when compaction failed. {reason} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not compact the conversation. {reason}'**
  String contextMeterCompactFailed(String reason);

  /// Headline of the context sheet. {used} and {max} are token counts, formatted.
  ///
  /// In en, this message translates to:
  /// **'{used} of {max} tokens'**
  String contextUsedOf(String used, String max);

  /// Free tokens in the context window. {left} is the token count, formatted.
  ///
  /// In en, this message translates to:
  /// **'{left} left'**
  String contextLeft(String left);

  /// A share of the context window. {percent} is a whole number.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String contextPercent(int percent);

  /// No description provided for @contextSourceProvider.
  ///
  /// In en, this message translates to:
  /// **'Counted by the model provider'**
  String get contextSourceProvider;

  /// No description provided for @contextSourcePlusEstimate.
  ///
  /// In en, this message translates to:
  /// **'Counted by the model provider, plus an estimate of the newest messages'**
  String get contextSourcePlusEstimate;

  /// No description provided for @contextSourceEstimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate. The provider has not counted this chat yet'**
  String get contextSourceEstimate;

  /// No description provided for @contextPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'What fills it'**
  String get contextPartsTitle;

  /// No description provided for @contextPartsNote.
  ///
  /// In en, this message translates to:
  /// **'Each part is an estimate, so the parts can add up to a little more or less than the total.'**
  String get contextPartsNote;

  /// Value of one part of the context window: its tokens, then its share. Both are already formatted.
  ///
  /// In en, this message translates to:
  /// **'{tokens} · {percent}'**
  String contextPartRow(String tokens, String percent);

  /// No description provided for @contextPartUnder1.
  ///
  /// In en, this message translates to:
  /// **'<1%'**
  String get contextPartUnder1;

  /// No description provided for @contextPartSystemPrompt.
  ///
  /// In en, this message translates to:
  /// **'System prompt'**
  String get contextPartSystemPrompt;

  /// No description provided for @contextPartTools.
  ///
  /// In en, this message translates to:
  /// **'Tool definitions'**
  String get contextPartTools;

  /// No description provided for @contextPartRules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get contextPartRules;

  /// No description provided for @contextPartSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills list'**
  String get contextPartSkills;

  /// No description provided for @contextPartMcp.
  ///
  /// In en, this message translates to:
  /// **'MCP tools'**
  String get contextPartMcp;

  /// No description provided for @contextPartSubagents.
  ///
  /// In en, this message translates to:
  /// **'Sub-agents'**
  String get contextPartSubagents;

  /// No description provided for @contextPartMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get contextPartMemory;

  /// No description provided for @contextPartConversation.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get contextPartConversation;

  /// No description provided for @contextFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get contextFree;

  /// No description provided for @contextFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Context files'**
  String get contextFilesTitle;

  /// No description provided for @contextFileTruncated.
  ///
  /// In en, this message translates to:
  /// **'Cut short: longer than the file limit'**
  String get contextFileTruncated;

  /// No description provided for @contextFileFlagged.
  ///
  /// In en, this message translates to:
  /// **'Loaded, but it looks like a prompt injection. Check the file'**
  String get contextFileFlagged;

  /// No description provided for @contextFileShadowed.
  ///
  /// In en, this message translates to:
  /// **'Not loaded: a file of higher priority is used'**
  String get contextFileShadowed;

  /// No description provided for @contextFileBlocked.
  ///
  /// In en, this message translates to:
  /// **'Not loaded: blocked by the prompt-injection check'**
  String get contextFileBlocked;

  /// No description provided for @contextFileEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not loaded: the file is empty'**
  String get contextFileEmpty;

  /// No description provided for @contextFileUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Not loaded: the file cannot be read'**
  String get contextFileUnreadable;

  /// No description provided for @contextFileSuppressed.
  ///
  /// In en, this message translates to:
  /// **'Not loaded: outside the bot\'s folder'**
  String get contextFileSuppressed;

  /// No description provided for @contextFileNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Not loaded'**
  String get contextFileNotLoaded;

  /// No description provided for @contextTotalsTitle.
  ///
  /// In en, this message translates to:
  /// **'This conversation'**
  String get contextTotalsTitle;

  /// No description provided for @contextReasoning.
  ///
  /// In en, this message translates to:
  /// **'Reasoning tokens'**
  String get contextReasoning;

  /// No description provided for @contextCacheHits.
  ///
  /// In en, this message translates to:
  /// **'Prompt cache hits'**
  String get contextCacheHits;

  /// No description provided for @contextCalls.
  ///
  /// In en, this message translates to:
  /// **'Model calls'**
  String get contextCalls;

  /// No description provided for @contextCompactions.
  ///
  /// In en, this message translates to:
  /// **'Compactions'**
  String get contextCompactions;

  /// Error when the breakdown of the context could not load. {reason} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not load the breakdown. {reason}'**
  String contextBreakdownFailed(String reason);

  /// No description provided for @contextRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get contextRetry;

  /// No description provided for @chatMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get chatMoreActions;

  /// No description provided for @composerModelAndEffort.
  ///
  /// In en, this message translates to:
  /// **'Model and effort'**
  String get composerModelAndEffort;

  /// No description provided for @chatToolStateDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get chatToolStateDone;

  /// No description provided for @sidebarReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get sidebarReconnect;

  /// No description provided for @spinnerLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get spinnerLoading;

  /// Spoken label of the run now button of a job. {name} is the job name.
  ///
  /// In en, this message translates to:
  /// **'Run {name} now'**
  String botCronRunNowNamed(String name);

  /// Spoken label of the delete button of a job. {name} is the job name.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String botCronDeleteNamed(String name);

  /// Subtitle of a job: its schedule, then when it runs next.
  ///
  /// In en, this message translates to:
  /// **'{schedule} · {next}'**
  String botCronScheduleAndNext(String schedule, String next);

  /// A range of weekdays, such as Mon-Fri. {first} and {last} are the day names.
  ///
  /// In en, this message translates to:
  /// **'{first}–{last}'**
  String botCronWeekdayRange(String first, String last);

  /// No description provided for @botCronListSeparator.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get botCronListSeparator;

  /// No description provided for @botCronStatusError.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get botCronStatusError;

  /// No description provided for @botCronStatusDeliveryFailed.
  ///
  /// In en, this message translates to:
  /// **'Delivery failed'**
  String get botCronStatusDeliveryFailed;

  /// No description provided for @sidebarRailLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load bots. Retry'**
  String get sidebarRailLoadFailed;

  /// No description provided for @chatMessageActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Message actions'**
  String get chatMessageActionsLabel;

  /// No description provided for @chatRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Record voice message'**
  String get chatRecordButton;

  /// No description provided for @chatRecordStop.
  ///
  /// In en, this message translates to:
  /// **'Stop and send recording'**
  String get chatRecordStop;

  /// No description provided for @chatRecordingCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get chatRecordingCancel;

  /// No description provided for @chatRecordingTap.
  ///
  /// In en, this message translates to:
  /// **'Recording… tap the mic to send'**
  String get chatRecordingTap;

  /// Spoken label of the more actions button when messages are hidden. {count} is how many.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{More actions, 1 hidden message} other{More actions, {count} hidden messages}}'**
  String chatMoreActionsHidden(int count);

  /// No description provided for @chatOpenFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not open this chat'**
  String get chatOpenFailedTitle;

  /// No description provided for @chatOpenFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Check the connection to the gateway, then try again.'**
  String get chatOpenFailedBody;

  /// No description provided for @chatSending.
  ///
  /// In en, this message translates to:
  /// **'Sending'**
  String get chatSending;

  /// No description provided for @mediaVideoFailed.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get mediaVideoFailed;

  /// No description provided for @mediaAudioFailed.
  ///
  /// In en, this message translates to:
  /// **'Audio unavailable'**
  String get mediaAudioFailed;

  /// No description provided for @mediaSeek.
  ///
  /// In en, this message translates to:
  /// **'Seek'**
  String get mediaSeek;

  /// Position in the media viewer. {index} is the picture shown, {count} all of them.
  ///
  /// In en, this message translates to:
  /// **'{index} / {count}'**
  String mediaViewerCounter(int index, int count);

  /// Time of an audio player. {position} and {duration} are already formatted.
  ///
  /// In en, this message translates to:
  /// **'{position} / {duration}'**
  String mediaAudioTime(String position, String duration);

  /// How long a tool ran. {seconds} is the number of seconds, with one decimal.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String chatToolDuration(String seconds);

  /// Two short pieces of text with a dot between them.
  ///
  /// In en, this message translates to:
  /// **'{first} · {second}'**
  String chatJoinDot(String first, String second);

  /// No description provided for @settingsGatewayUrlUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Remove the user name and password from the address and sign in below instead'**
  String get settingsGatewayUrlUserInfo;

  /// No description provided for @settingsDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'The gateway settings you changed are not saved.'**
  String get settingsDiscardBody;

  /// No description provided for @settingsPasswordShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get settingsPasswordShow;

  /// No description provided for @settingsPasswordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get settingsPasswordHide;

  /// No description provided for @settingsTokenShow.
  ///
  /// In en, this message translates to:
  /// **'Show token'**
  String get settingsTokenShow;

  /// No description provided for @settingsTokenHide.
  ///
  /// In en, this message translates to:
  /// **'Hide token'**
  String get settingsTokenHide;

  /// No description provided for @settingsTokenUse.
  ///
  /// In en, this message translates to:
  /// **'Use this token'**
  String get settingsTokenUse;

  /// Between the names of the sign-in providers a gateway uses, in the sentence that says this app cannot sign in with them.
  ///
  /// In en, this message translates to:
  /// **', '**
  String get settingsAuthProviderSeparator;

  /// Between the questions of one clarify request, in the text of its notification.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get notificationQuestionSeparator;

  /// Notice when the phone left shared files out: over the size limit of a file or a share, or over the count limit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file was left out because it is over the limit} other{{count} files were left out because they are over the limit}}'**
  String shareSkipped(int count);

  /// Size of a file under 1 KB. The size is a whole number.
  ///
  /// In en, this message translates to:
  /// **'{size} B'**
  String fileSizeB(String size);

  /// Size of a file in kilobytes (1024 bytes). The size is already formatted for the locale.
  ///
  /// In en, this message translates to:
  /// **'{size} KB'**
  String fileSizeKB(String size);

  /// Size of a file in megabytes. The size is already formatted for the locale.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String fileSizeMB(String size);

  /// Size of a file in gigabytes. The size is already formatted for the locale.
  ///
  /// In en, this message translates to:
  /// **'{size} GB'**
  String fileSizeGB(String size);

  /// Link under the gateway URL in Settings, and the title of the setup guide it opens.
  ///
  /// In en, this message translates to:
  /// **'How to connect'**
  String get connectGuideTitle;

  /// Setup guide in Markdown: how to run a Hermes gateway the app can reach. Keep the code blocks, commands, file paths and variable names as they are.
  ///
  /// In en, this message translates to:
  /// **'Pomelu connects to Hermes Agent on your own computer. Do these steps one time.\n\n### 1. Install Hermes Agent\nInstall [Hermes Agent](https://hermes-agent.nousresearch.com/docs/getting-started/installation) 0.21.5 or newer on your computer. To update it:\n\n```\nhermes update\n```\n\n### 2. Set a username and password\nAdd these lines to `~/.hermes/.env` on the computer. Use your own username and a strong password:\n\n```\nHERMES_DASHBOARD_BASIC_AUTH_USERNAME=me\nHERMES_DASHBOARD_BASIC_AUTH_PASSWORD=a-strong-password\nHERMES_DASHBOARD_BASIC_AUTH_SECRET=paste-the-secret-here\n```\n\nTo make the secret, run:\n\n```\nopenssl rand -base64 32\n```\n\n### 3. Start the gateway\nRun this on the computer and keep it running:\n\n```\nhermes dashboard --host 0.0.0.0 --no-open\n```\n\n### 4. Find the address\n- **Same Wi-Fi:** `http://` + the computer\'s IP address + `:9119`, for example `http://192.168.1.20:9119`.\n- **Away from home:** use a private network such as [Tailscale](https://tailscale.com), or put the gateway behind `https://`.\n\n### 5. Connect the app\nIn Settings, type the address in **Gateway URL**. Sign in with the username and password. Tap **Test connection**, then **Save and connect**.\n\n### 6. Let your bots message you\nSo that your bots can message you first, also while the app is closed (\"message me every day at 7\"), install the Pomelu plugin on the computer, then restart Hermes:\n\n```\nhermes plugins install ateymoori/pomelu-hermes-plugin --enable\nhermes pomelu setup\n```\n\nThe phone then rings by push when a bot writes in its chat. Pomelu registers the phone by itself; keep **Notify me** on.\n\n### If it does not connect\n- **HTTP failed:** check the address. Make sure the computer is on and its firewall allows port 9119.\n- **WebSocket failed:** a proxy or tunnel in front of the gateway must allow WebSockets.\n- **Gateway too old:** run `hermes update` on the computer.'**
  String get connectGuideBody;

  /// Button in the bot details header, and the title of the page it opens.
  ///
  /// In en, this message translates to:
  /// **'Edit bot'**
  String get botEdit;

  /// No description provided for @botEditName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get botEditName;

  /// Under the name field. {id} is the bot's Hermes profile id, which does not change.
  ///
  /// In en, this message translates to:
  /// **'Profile: {id}'**
  String botEditProfileId(String id);

  /// No description provided for @botEditChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get botEditChoosePhoto;

  /// No description provided for @botEditRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get botEditRemovePhoto;

  /// No description provided for @botEditPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open your photos'**
  String get botEditPhotoFailed;

  /// No description provided for @botEditPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large. Choose a smaller one.'**
  String get botEditPhotoTooLarge;

  /// No description provided for @botEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get botEditSave;

  /// Error on the edit bot page. {message} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not save: {message}'**
  String botEditSaveFailed(String message);

  /// No description provided for @botEditDiscardBody.
  ///
  /// In en, this message translates to:
  /// **'The changes to this bot are not saved.'**
  String get botEditDiscardBody;

  /// No description provided for @botDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete bot'**
  String get botDelete;

  /// Confirm title. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String botDeleteTitle(String name);

  /// No description provided for @botDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes the bot and its chats, memory and files on the gateway. You cannot undo this.'**
  String get botDeleteBody;

  /// Sidebar button and the title of the sheet that asks for the new bot's name.
  ///
  /// In en, this message translates to:
  /// **'New bot'**
  String get botNew;

  /// No description provided for @botNewCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get botNewCreate;

  /// Snack bar after a failed create. {message} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not create the bot: {message}'**
  String botNewFailed(String message);

  /// Heading over the ready-made bot pictures on the edit bot page.
  ///
  /// In en, this message translates to:
  /// **'Characters'**
  String get botEditCharacters;

  /// Spoken label of one ready-made bot picture.
  ///
  /// In en, this message translates to:
  /// **'Character {number}'**
  String botEditCharacter(int number);

  /// Heading over the photo actions on the edit bot page.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get botEditPicture;

  /// Chat header button and menu row that open the bot's screen: its own desktop, which it uses with its computer and browser tools.
  ///
  /// In en, this message translates to:
  /// **'Screen'**
  String get screenAction;

  /// Spoken label of the chat header's screen button while a person (this phone, another device) drives the bot's screen, so the bot cannot use it.
  ///
  /// In en, this message translates to:
  /// **'Screen: a person has control'**
  String get screenActionHeld;

  /// Spoken label of the live desktop on the screen page. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s screen'**
  String screenLabel(String name);

  /// No description provided for @screenBotInControl.
  ///
  /// In en, this message translates to:
  /// **'Bot in control'**
  String get screenBotInControl;

  /// No description provided for @screenYouInControl.
  ///
  /// In en, this message translates to:
  /// **'You are in control'**
  String get screenYouInControl;

  /// Status on the screen page: a person on another device (or this app before it lost its connection) drives the screen.
  ///
  /// In en, this message translates to:
  /// **'Another viewer in control'**
  String get screenOtherInControl;

  /// No description provided for @screenConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting…'**
  String get screenConnecting;

  /// No description provided for @screenOff.
  ///
  /// In en, this message translates to:
  /// **'Screen is off'**
  String get screenOff;

  /// Under 'Screen is off'. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'Start it to watch what {name} does.'**
  String screenOffMessage(String name);

  /// No description provided for @screenStart.
  ///
  /// In en, this message translates to:
  /// **'Start screen'**
  String get screenStart;

  /// Title over the gateway's reason (low memory on its host) why the screen cannot start now.
  ///
  /// In en, this message translates to:
  /// **'The screen cannot start'**
  String get screenCannotStart;

  /// No description provided for @screenNone.
  ///
  /// In en, this message translates to:
  /// **'No screen'**
  String get screenNone;

  /// No description provided for @screenNoneMessage.
  ///
  /// In en, this message translates to:
  /// **'This bot\'s gateway has no screen.'**
  String get screenNoneMessage;

  /// No description provided for @screenEnded.
  ///
  /// In en, this message translates to:
  /// **'Stream ended'**
  String get screenEnded;

  /// No description provided for @screenEndedMessage.
  ///
  /// In en, this message translates to:
  /// **'The picture from the screen stopped.'**
  String get screenEndedMessage;

  /// No description provided for @screenReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get screenReconnect;

  /// No description provided for @screenTakeOver.
  ///
  /// In en, this message translates to:
  /// **'Take over'**
  String get screenTakeOver;

  /// No description provided for @screenHandBack.
  ///
  /// In en, this message translates to:
  /// **'Hand back'**
  String get screenHandBack;

  /// Menu row and confirm button: ends a control another viewer (or a lost connection of this app) holds, so the bot can use its screen again. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'Give control to {name}'**
  String screenGiveBack(String name);

  /// Confirm title. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'Give control back to {name}?'**
  String screenGiveBackTitle(String name);

  /// Confirm text. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'Someone else has control now, on another device or in this app before it lost its connection. {name} can use its screen again.'**
  String screenGiveBackBody(String name);

  /// No description provided for @screenTakeOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Take over from the other viewer?'**
  String get screenTakeOverTitle;

  /// Confirm text. {name} is the bot's name.
  ///
  /// In en, this message translates to:
  /// **'Someone else has control of {name}\'s screen. They can only watch once you take over.'**
  String screenTakeOverBody(String name);

  /// No description provided for @screenControlTaken.
  ///
  /// In en, this message translates to:
  /// **'Another viewer took control. You are watching.'**
  String get screenControlTaken;

  /// Snack bar. {message} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not start the screen: {message}'**
  String screenStartFailed(String message);

  /// Snack bar. {message} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not take over: {message}'**
  String screenTakeOverFailed(String message);

  /// Snack bar. {message} is the failure sentence.
  ///
  /// In en, this message translates to:
  /// **'Could not hand back: {message}'**
  String screenHandBackFailed(String message);

  /// Button that zooms the view of the bot's desktop back out to all of it.
  ///
  /// In en, this message translates to:
  /// **'Whole screen'**
  String get screenFit;

  /// Button that zooms the view of the bot's desktop in until it fills a tall window, following where the bot works.
  ///
  /// In en, this message translates to:
  /// **'Fill screen'**
  String get screenFill;

  /// No description provided for @screenKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get screenKeyboard;

  /// Button on the screen page: the next tap picks up what is under it on the bot's desktop, the tap after drops it there.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop'**
  String get screenDrag;

  /// No description provided for @screenDragCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel drag'**
  String get screenDragCancel;

  /// Status on the screen page after Drag and drop: the next tap picks up what is under it.
  ///
  /// In en, this message translates to:
  /// **'Tap what to drag'**
  String get screenDragPick;

  /// Status on the screen page while something is picked up: pan or zoom the view, then tap where it goes.
  ///
  /// In en, this message translates to:
  /// **'Tap where to drop it'**
  String get screenDragDrop;

  /// Spoken label of the hidden field the keyboard types into; each key goes to the bot's desktop.
  ///
  /// In en, this message translates to:
  /// **'Type on the bot\'s screen'**
  String get screenTyping;

  /// Types the phone's clipboard on the bot's desktop.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get screenPaste;

  /// No description provided for @screenPasteEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to paste'**
  String get screenPasteEmpty;

  /// No description provided for @screenPasteTooLong.
  ///
  /// In en, this message translates to:
  /// **'The clipboard is too long for the screen.'**
  String get screenPasteTooLong;

  /// Snack bar after Paste with a long text: it went onto the bot's desktop clipboard only, for that desktop's own Paste (Ctrl+V).
  ///
  /// In en, this message translates to:
  /// **'Too long to type. It is on the screen\'s clipboard: paste it there.'**
  String get screenPasteOnClipboard;

  /// No description provided for @screenKeyEscape.
  ///
  /// In en, this message translates to:
  /// **'Escape'**
  String get screenKeyEscape;

  /// Text on the key row's Escape key, as printed on a keyboard.
  ///
  /// In en, this message translates to:
  /// **'Esc'**
  String get screenKeyEscapeCap;

  /// Text on the key row's Control key, as printed on a keyboard.
  ///
  /// In en, this message translates to:
  /// **'Ctrl'**
  String get screenKeyControlCap;

  /// No description provided for @screenKeyTab.
  ///
  /// In en, this message translates to:
  /// **'Tab'**
  String get screenKeyTab;

  /// Spoken label of the key row's Ctrl: held down with the next key.
  ///
  /// In en, this message translates to:
  /// **'Control'**
  String get screenKeyControl;

  /// No description provided for @screenKeyAlt.
  ///
  /// In en, this message translates to:
  /// **'Alt'**
  String get screenKeyAlt;

  /// No description provided for @screenKeyLeft.
  ///
  /// In en, this message translates to:
  /// **'Left arrow'**
  String get screenKeyLeft;

  /// No description provided for @screenKeyUp.
  ///
  /// In en, this message translates to:
  /// **'Up arrow'**
  String get screenKeyUp;

  /// No description provided for @screenKeyRight.
  ///
  /// In en, this message translates to:
  /// **'Right arrow'**
  String get screenKeyRight;

  /// No description provided for @screenKeyDown.
  ///
  /// In en, this message translates to:
  /// **'Down arrow'**
  String get screenKeyDown;

  /// No description provided for @screenKeyboardHide.
  ///
  /// In en, this message translates to:
  /// **'Hide keyboard'**
  String get screenKeyboardHide;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
