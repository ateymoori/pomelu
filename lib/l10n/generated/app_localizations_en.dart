// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pomelu';

  @override
  String get navSettings => 'Settings';

  @override
  String get navBots => 'Bots';

  @override
  String get connStateConnected => 'Connected';

  @override
  String get connStateConnecting => 'Connecting…';

  @override
  String get connStateReconnecting => 'Reconnecting…';

  @override
  String get connStateDisconnected => 'Offline';

  @override
  String get connStateAuthRequired => 'Sign in required';

  @override
  String get connStateNotConfigured => 'No gateway';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGatewaySection => 'Remote gateway';

  @override
  String get settingsGatewayUrl => 'Gateway URL';

  @override
  String get settingsGatewayUrlHint => 'https://hermes.example.com';

  @override
  String get settingsGatewayUrlInvalid => 'Enter a valid http(s) URL';

  @override
  String get settingsNotEncrypted =>
      'Not encrypted. This address sends everything, your password and messages too, readable over the internet. Use https:// if the gateway has it.';

  @override
  String get settingsNotEncryptedConfirmTitle =>
      'Send the password unencrypted?';

  @override
  String get settingsNotEncryptedConfirmBody =>
      'This address is plain http:// over the internet. Anyone on the way can read the password, and use it.';

  @override
  String get settingsNotEncryptedConfirmAction => 'Send anyway';

  @override
  String settingsGatewayTooOld(String version, String minimum) {
    return 'This gateway runs Hermes $version. This app needs Hermes $minimum or newer: update Hermes.';
  }

  @override
  String get settingsAuthDetecting => 'Detecting…';

  @override
  String get settingsAuthNone => 'This gateway does not require sign-in';

  @override
  String get settingsAuthBasic => 'Username and password';

  @override
  String get settingsAuthToken => 'Session token';

  @override
  String settingsAuthUnsupported(String provider) {
    return 'This gateway uses $provider, which this app cannot sign in with yet';
  }

  @override
  String get settingsUsername => 'Username';

  @override
  String get settingsPassword => 'Password';

  @override
  String get settingsToken => 'Token';

  @override
  String get settingsTokenHint => 'Paste the dashboard session token';

  @override
  String get settingsSignInSection => 'Sign-in';

  @override
  String get settingsSignIn => 'Sign in';

  @override
  String get settingsSigningIn => 'Signing in…';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String settingsSignedInAs(String user) {
    return 'Signed in as $user';
  }

  @override
  String get settingsTestConnection => 'Test connection';

  @override
  String get settingsTesting => 'Testing…';

  @override
  String settingsTestOk(String version) {
    return 'Reachable · gateway $version';
  }

  @override
  String settingsTestHttpFail(String reason) {
    return 'HTTP failed: $reason';
  }

  @override
  String settingsTestWsFail(String reason) {
    return 'HTTP ok, WebSocket failed: $reason';
  }

  @override
  String settingsTestWsFailDetail(String reason, String detail) {
    return 'HTTP ok, WebSocket failed: $reason ($detail)';
  }

  @override
  String get settingsSave => 'Save and connect';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLicenses => 'Open-source licenses';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsLinkFailed => 'Could not open the link';

  @override
  String get settingsGatewayLabel => 'Gateway';

  @override
  String get chatNewConversation => 'New conversation';

  @override
  String get sidebarNoBots => 'No bots found on this gateway';

  @override
  String get sidebarRunning => 'Working…';

  @override
  String chatPlaceholder(String bot) {
    return 'Message $bot';
  }

  @override
  String get chatSend => 'Send';

  @override
  String get chatStop => 'Stop';

  @override
  String get chatAttach => 'Attach';

  @override
  String get chatRecord => 'Hold to record';

  @override
  String get chatRecording =>
      'Recording… release to send, slide back to cancel';

  @override
  String get chatTranscribing => 'Turning speech into text…';

  @override
  String get chatVoiceEmpty => 'No speech heard';

  @override
  String get chatVoiceFailed => 'Could not turn the recording into text';

  @override
  String get chatThinking => 'Thinking';

  @override
  String chatPlanProgress(int done, int total) {
    return 'Plan · $done of $total';
  }

  @override
  String get chatPlanDone => 'Done';

  @override
  String get chatPlanWorking => 'Working on';

  @override
  String get chatPlanCancelled => 'Cancelled';

  @override
  String get chatPlanToDo => 'To do';

  @override
  String chatToolRunning(String tool) {
    return 'Running $tool';
  }

  @override
  String chatToolDone(String tool) {
    return '$tool';
  }

  @override
  String chatToolFailed(String tool) {
    return '$tool failed';
  }

  @override
  String chatToolsRunning(String tool, int count) {
    return 'Running $tool · $count tools';
  }

  @override
  String chatToolsDone(int count) {
    return '$count tools';
  }

  @override
  String chatToolsFailed(int count, int failed) {
    return '$count tools · $failed failed';
  }

  @override
  String get chatCopied => 'Copied';

  @override
  String get chatLinkCopied =>
      'This link cannot open from a chat. It was copied.';

  @override
  String get chatCopy => 'Copy';

  @override
  String get chatFailedToSend => 'Not sent · tap to retry';

  @override
  String chatEmptyTitle(String bot) {
    return 'Say hello to $bot';
  }

  @override
  String get chatEmptyBody => 'Messages stream live from your gateway.';

  @override
  String get chatSelectTitle => 'Pick a bot';

  @override
  String get chatSelectBody => 'Open the menu to choose where to start.';

  @override
  String get chatScrollToBottom => 'Jump to latest';

  @override
  String chatErrorTurn(String message) {
    return 'The bot hit an error: $message';
  }

  @override
  String get chatCopyMarkdown => 'Copy as Markdown';

  @override
  String get chatQuoteReply => 'Quote reply';

  @override
  String get chatResend => 'Send again';

  @override
  String get chatEditResend => 'Edit and resend';

  @override
  String get chatEditMessage => 'Edit message';

  @override
  String get chatDiscarded => 'Discarded';

  @override
  String get chatAlreadySending => 'This message is already on its way';

  @override
  String get chatQueueFull =>
      'Too many messages are waiting to be sent. Send or discard some first.';

  @override
  String get chatHide => 'Hide on this phone';

  @override
  String get chatReport => 'Report';

  @override
  String get chatReportHint =>
      'Opens an email of this reply to Royan AB, the app\'s developer';

  @override
  String get chatReportTitle => 'Why report this reply?';

  @override
  String get chatReportHarmful => 'Harmful or dangerous';

  @override
  String get chatReportHateful => 'Hateful or harassing';

  @override
  String get chatReportSexual => 'Sexual content';

  @override
  String get chatReportMisleading => 'False or misleading';

  @override
  String get chatReportOther => 'Something else';

  @override
  String chatReportFailed(String email) {
    return 'No mail app found. Write to $email.';
  }

  @override
  String get chatHideHint => 'Only hides it here. The bot still remembers it.';

  @override
  String get chatHidden => 'Hidden on this phone';

  @override
  String get chatUndo => 'Undo';

  @override
  String get chatShowHidden => 'Show hidden messages';

  @override
  String chatHiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hidden messages',
      one: '1 hidden message',
    );
    return '$_temp0';
  }

  @override
  String get chatDeleteFrom => 'Delete from here';

  @override
  String get chatDeleteFromHint =>
      'Removes this exchange and everything after it';

  @override
  String get chatDeleteFromTitle => 'Delete from here?';

  @override
  String chatDeleteFromBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The bot will forget this exchange and $count later ones. This cannot be undone.',
      one: 'The bot will forget this exchange and 1 later one. This cannot be undone.',
      zero: 'The bot will forget this exchange. This cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String get chatDeleteAction => 'Delete';

  @override
  String get chatDeleted => 'Deleted';

  @override
  String get chatDeleteBusy => 'Wait for the bot to finish first';

  @override
  String get chatDeleteUnsaved => 'Not saved yet. Try again in a moment.';

  @override
  String get chatDeleteFailed => 'Could not delete';

  @override
  String chatQueuedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages waiting to send',
      one: '1 message waiting to send',
    );
    return '$_temp0';
  }

  @override
  String chatFailedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages were not sent',
      one: '1 message was not sent',
    );
    return '$_temp0';
  }

  @override
  String get chatOfflineNotice =>
      'Offline · messages send when the gateway is back';

  @override
  String chatUploadProgress(String name, int done, int total) {
    return 'Uploading $name ($done/$total)';
  }

  @override
  String attachBatchTooLarge(String limit) {
    return 'These attachments total more than $limit';
  }

  @override
  String get chatImageFailed => 'Image unavailable';

  @override
  String get chatImageLoading => 'Loading image…';

  @override
  String get attachPhoto => 'Photo library';

  @override
  String get attachCamera => 'Camera';

  @override
  String get attachVideo => 'Video';

  @override
  String get attachFile => 'File';

  @override
  String get attachLocation => 'Location';

  @override
  String get locationTitle => 'Share location';

  @override
  String get locationShare => 'Share';

  @override
  String get locationMine => 'My location';

  @override
  String get locationResolving => 'Finding the address…';

  @override
  String get locationNoAddress => 'No address for this place';

  @override
  String get locationOff =>
      'Your location is not available. Move the map to the place.';

  @override
  String get locationTilesFailed =>
      'The map could not load. Check the connection; the pin still works.';

  @override
  String locationMessage(String address, String latitude, String longitude) {
    return 'Location: $address\nLatitude: $latitude\nLongitude: $longitude';
  }

  @override
  String locationMessageNoAddress(String latitude, String longitude) {
    return 'Location\nLatitude: $latitude\nLongitude: $longitude';
  }

  @override
  String attachTooLarge(String name, String limit) {
    return '$name is larger than $limit';
  }

  @override
  String get attachRemove => 'Remove';

  @override
  String get attachShare => 'Share';

  @override
  String get attachOpen => 'Open';

  @override
  String get attachSaveToFiles => 'Save to Files';

  @override
  String attachSaved(String name) {
    return 'Saved $name';
  }

  @override
  String attachSaveFailed(String name) {
    return 'Could not save $name';
  }

  @override
  String attachFileActions(String name) {
    return 'Actions for $name';
  }

  @override
  String attachNoApp(String name) {
    return 'No app on this phone can open $name';
  }

  @override
  String get attachPickFailed =>
      'Could not add the file. Check that the app may use the camera or files.';

  @override
  String attachDownloadFailed(String name) {
    return 'Could not download $name';
  }

  @override
  String get attachVoiceNote => 'Voice note';

  @override
  String get attachMicDenied => 'Microphone access is needed to record';

  @override
  String get shareTitle => 'Send to';

  @override
  String shareItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get shareNoGateway => 'Set up a gateway first';

  @override
  String get errorNetwork => 'Cannot reach the gateway';

  @override
  String get errorUnauthorized => 'Sign in to continue';

  @override
  String get errorForbidden => 'This account is not allowed';

  @override
  String get errorHostRefused =>
      'The gateway refused this address. Use the address the gateway is set up for (its host name and port).';

  @override
  String get errorNotSupported => 'Not supported by this gateway version';

  @override
  String errorGatewayTooOld(String version, String minimum) {
    return 'This gateway runs Hermes $version; this app needs $minimum or newer. Update Hermes.';
  }

  @override
  String get errorChatOpenElsewhere =>
      'This chat is open in another Hermes window or terminal. Use it there, or start a new conversation here with /new.';

  @override
  String get errorGatewayFull =>
      'The gateway has as many chats open as it allows. Close one, then try again.';

  @override
  String get errorProtocol =>
      'The gateway sent something this app did not understand';

  @override
  String errorServer(String message) {
    return 'Gateway error: $message';
  }

  @override
  String get errorUnknown => 'Something went wrong';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get actionOpenMenu => 'Open menu';

  @override
  String get discardTitle => 'Discard your changes?';

  @override
  String get actionOpenSettings => 'Open settings';

  @override
  String get timeNow => 'now';

  @override
  String timeMinutes(int n) {
    return '${n}m';
  }

  @override
  String timeHours(int n) {
    return '${n}h';
  }

  @override
  String get timeToday => 'Today';

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String get timeTomorrow => 'Tomorrow';

  @override
  String get chatDismiss => 'Dismiss';

  @override
  String get chatShare => 'Share message';

  @override
  String get chatReadAloud => 'Read aloud';

  @override
  String get chatStopReading => 'Stop reading';

  @override
  String get chatReadingAloud => 'Reading aloud in the bot\'s voice…';

  @override
  String get chatToolOutput => 'Output';

  @override
  String get chatApprovalTitle => 'Approval needed';

  @override
  String get chatChoiceOnce => 'Allow once';

  @override
  String get chatChoiceAlways => 'Always allow';

  @override
  String get chatChoiceSession => 'Allow for this chat';

  @override
  String get chatChoiceDeny => 'Deny';

  @override
  String get chatApprovalRisky =>
      'The security scan flagged this command as risky.';

  @override
  String get chatClarifyTitle => 'Question';

  @override
  String get chatClarifyHint => 'Type your answer';

  @override
  String get chatClarifyOther => 'Other answer';

  @override
  String get chatClarifyRecommended => 'Recommended';

  @override
  String chatClarifyStep(int number, int total) {
    return 'Question $number of $total';
  }

  @override
  String get chatRequestSkip => 'Skip';

  @override
  String get chatRequestSend => 'Send';

  @override
  String get chatInputSudoTitle => 'Password needed';

  @override
  String get chatInputSecretTitle => 'Secret needed';

  @override
  String get chatInputHint => 'Enter the value';

  @override
  String get chatInputShow => 'Show';

  @override
  String get chatInputHide => 'Hide';

  @override
  String attachTooMany(int count) {
    return 'You can attach at most $count files';
  }

  @override
  String get mediaPlay => 'Play';

  @override
  String get mediaPause => 'Pause';

  @override
  String get sidebarRefresh => 'Refresh';

  @override
  String get sidebarLoadFailed => 'Could not load bots';

  @override
  String get sidebarNoBotsBody => 'This gateway has no visible bots yet.';

  @override
  String get shellNoGatewayBody =>
      'Connect the app to your gateway to start chatting.';

  @override
  String get shareEmpty => 'Nothing to send';

  @override
  String get shareEmptyBody =>
      'Share a file or some text from another app to start.';

  @override
  String get settingsAboutSection => 'About';

  @override
  String get sidebarCollapseMenu => 'Collapse menu';

  @override
  String get sidebarExpandMenu => 'Expand menu';

  @override
  String get composerModel => 'Model';

  @override
  String get composerEffort => 'Effort';

  @override
  String get composerEffortAuto => 'Auto';

  @override
  String get composerPickEffort => 'Reasoning effort';

  @override
  String get composerEffortNone => 'Off';

  @override
  String get composerEffortMinimal => 'Minimal';

  @override
  String get composerEffortLow => 'Low';

  @override
  String get composerEffortMedium => 'Medium';

  @override
  String get composerEffortHigh => 'High';

  @override
  String get composerEffortXhigh => 'Extra high';

  @override
  String get composerEffortMax => 'Max';

  @override
  String get composerEffortUltra => 'Ultra';

  @override
  String get composerNoModels => 'No models available';

  @override
  String get composerSearchModels => 'Search models';

  @override
  String get composerNoModelMatch => 'No models match';

  @override
  String get slashNoMatch => 'No matching command';

  @override
  String get slashDone => 'Done';

  @override
  String get slashRunning => 'Running…';

  @override
  String get slashFailed => 'Command failed';

  @override
  String get slashNotReady =>
      'The chat is not connected yet. Try the command again in a moment.';

  @override
  String get slashNewDesc =>
      'Start a fresh conversation. The old one stays above.';

  @override
  String get slashRestartDesc => 'Restart the gateway.';

  @override
  String get slashUpdateDesc => 'Update the gateway to the latest version.';

  @override
  String get slashCompactDesc => 'Summarize older turns to free up context.';

  @override
  String get slashRestartConfirmTitle => 'Restart the gateway?';

  @override
  String get slashRestartConfirmBody =>
      'Every bot pauses for a moment. Running tasks finish first.';

  @override
  String get slashRestartConfirmAction => 'Restart';

  @override
  String get slashUpdateConfirmTitle => 'Update the gateway?';

  @override
  String get slashUpdateConfirmBody =>
      'Installs the latest version and restarts the gateway. The app reconnects by itself.';

  @override
  String get slashUpdateConfirmAction => 'Update';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotificationsEnabled => 'Notify me';

  @override
  String get settingsNotificationsEnabledBody =>
      'Notices from the bot and finished background tasks';

  @override
  String get settingsNotificationsPushOn =>
      'Bots reach you by push, also while the app is closed';

  @override
  String get settingsNotificationsPushMissing =>
      'To get bot messages while the app is closed, add the Pomelu plugin to Hermes (How to connect, step 6)';

  @override
  String get settingsNotificationsDenied => 'Blocked in system settings';

  @override
  String get settingsKeepAlive => 'Stay connected in the background';

  @override
  String get settingsKeepAliveBody =>
      'Keeps the gateway connection alive with the screen off. Shows a quiet ongoing notification.';

  @override
  String get notificationServiceTitle => 'Stay connected';

  @override
  String get notificationServiceBody => 'Connected to your gateway';

  @override
  String get notificationServiceParkedBody =>
      'Gateway unreachable. Paused until you open the app.';

  @override
  String get notificationNoticeTitle => 'Your agent';

  @override
  String get notificationWarningTitle => 'Your agent · warning';

  @override
  String get notificationErrorTitle => 'Your agent · error';

  @override
  String get notificationBackgroundTitle => 'Background task finished';

  @override
  String get notificationBackgroundFailedTitle => 'Background task failed';

  @override
  String get notificationQuestionTitle => 'Your agent has a question';

  @override
  String get notificationApprovalTitle => 'Your agent needs your approval';

  @override
  String get notificationInputTitle => 'Your agent needs a value';

  @override
  String get notificationChannelAlerts => 'Bot activity';

  @override
  String get notificationChannelAlertsBody =>
      'Notices from the bots and finished background tasks.';

  @override
  String get notificationMessageAttachment => 'Sent a file';

  @override
  String get notificationChannelMessages => 'Messages';

  @override
  String get notificationChannelMessagesBody =>
      'What your bots write while the app is closed.';

  @override
  String get notificationChannelConnection => 'Gateway connection';

  @override
  String get notificationChannelConnectionBody =>
      'Keeps the connection to your gateway open while the app is in the background.';

  @override
  String get chatDetailsSummary => 'Details';

  @override
  String get chatLinkYouTube => 'YouTube';

  @override
  String get chatOpenImage => 'Open image';

  @override
  String chatNewMessages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new messages',
      one: '1 new message',
    );
    return '$_temp0';
  }

  @override
  String get chatSearchOpen => 'Find in conversation';

  @override
  String get chatSearchClose => 'Close search';

  @override
  String get chatSearchHint => 'Find in conversation';

  @override
  String get chatSearchNext => 'Next match';

  @override
  String get chatSearchPrevious => 'Previous match';

  @override
  String get chatSearchNoMatches => 'No matches';

  @override
  String chatSearchProgress(int current, int total) {
    return '$current of $total';
  }

  @override
  String get botDetailsAction => 'Bot details';

  @override
  String get botDetailsSkills => 'Skills';

  @override
  String get botDetailsTools => 'Tools';

  @override
  String get botDetailsNoSkills => 'No skills turned on';

  @override
  String get botDetailsNoSkillsBody => 'This bot has no skills it can use.';

  @override
  String get botDetailsNoTools => 'No tools turned on';

  @override
  String get botDetailsNoToolsBody => 'This bot has no tools it can use.';

  @override
  String get botDetailsOther => 'Other';

  @override
  String get botDetailsInstructions => 'Instructions';

  @override
  String get botSoulEdit => 'Edit';

  @override
  String get botSoulEmptyTitle => 'No instructions yet';

  @override
  String get botSoulEmptyBody =>
      'This bot has no instructions file. It uses its default identity.';

  @override
  String get botSoulWrite => 'Write instructions';

  @override
  String get botSoulEditorTitle => 'Edit instructions';

  @override
  String get botSoulEditorHint => 'Describe who this bot is and how it works.';

  @override
  String get botSoulSave => 'Save';

  @override
  String get botSoulSaved => 'Saved. A new session uses it.';

  @override
  String botSoulSaveFailed(String message) {
    return 'Could not save: $message';
  }

  @override
  String get botSoulChangedTitle => 'Changed on the gateway';

  @override
  String get botSoulChangedBody =>
      'These instructions changed while you were editing. Saving replaces that version with yours.';

  @override
  String get botSoulReplace => 'Replace';

  @override
  String get botSoulDiscardBody => 'What you wrote is not saved.';

  @override
  String get botSoulEmptyConfirmTitle => 'Save empty instructions?';

  @override
  String get botSoulEmptyConfirmBody =>
      'This bot will use its default identity.';

  @override
  String get botSoulSaveEmpty => 'Save empty';

  @override
  String get botDetailsLoadFailed => 'Could not load';

  @override
  String get botDetailsCron => 'Cron';

  @override
  String get botCronEmptyTitle => 'No scheduled jobs';

  @override
  String get botCronEmptyBody => 'This bot has nothing scheduled.';

  @override
  String botCronEveryMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count minutes',
      one: 'Every minute',
    );
    return '$_temp0';
  }

  @override
  String botCronEveryHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count hours',
      one: 'Every hour',
    );
    return '$_temp0';
  }

  @override
  String botCronEveryDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every $count days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String botCronDaily(String time) {
    return 'Daily at $time';
  }

  @override
  String botCronWeekly(String days, String time) {
    return '$days at $time';
  }

  @override
  String botCronGatewayClock(String schedule) {
    return '$schedule, gateway time';
  }

  @override
  String botCronOnce(String when) {
    return 'Once, $when';
  }

  @override
  String botCronWhen(String day, String time) {
    return '$day, $time';
  }

  @override
  String botCronNext(String when) {
    return 'Next: $when';
  }

  @override
  String get botCronPaused => 'Paused';

  @override
  String get botCronCompleted => 'Completed';

  @override
  String get botCronNeverRan => 'Not run yet';

  @override
  String botCronLastRun(String when, String status) {
    return 'Last run: $when · $status';
  }

  @override
  String get botCronStatusOk => 'OK';

  @override
  String get botCronDeleteTitle => 'Delete this job?';

  @override
  String botCronDeleteBody(String name) {
    return '$name stops running. You cannot undo this.';
  }

  @override
  String get botCronDelete => 'Delete';

  @override
  String get mediaSave => 'Save to gallery';

  @override
  String get mediaSaved => 'Saved to gallery';

  @override
  String get mediaSaveFailed => 'Could not save image';

  @override
  String contextMeterUsed(int percent) {
    return 'Context window, $percent percent used';
  }

  @override
  String get contextMeterUnknown => 'Context usage unavailable';

  @override
  String get contextMeterTitle => 'Context usage';

  @override
  String get contextMeterInput => 'Input tokens';

  @override
  String get contextMeterOutput => 'Output tokens';

  @override
  String get contextMeterCompact => 'Compact';

  @override
  String get contextMeterCompactConfirm => 'Compact now';

  @override
  String get contextMeterCompactExplainer =>
      'Summarizes older turns so the conversation fits back inside the context window. This cannot be undone.';

  @override
  String contextMeterCompactFailed(String reason) {
    return 'Could not compact the conversation. $reason';
  }

  @override
  String contextUsedOf(String used, String max) {
    return '$used of $max tokens';
  }

  @override
  String contextLeft(String left) {
    return '$left left';
  }

  @override
  String contextPercent(int percent) {
    return '$percent%';
  }

  @override
  String get contextSourceProvider => 'Counted by the model provider';

  @override
  String get contextSourcePlusEstimate =>
      'Counted by the model provider, plus an estimate of the newest messages';

  @override
  String get contextSourceEstimate =>
      'Estimate. The provider has not counted this chat yet';

  @override
  String get contextPartsTitle => 'What fills it';

  @override
  String get contextPartsNote =>
      'Each part is an estimate, so the parts can add up to a little more or less than the total.';

  @override
  String contextPartRow(String tokens, String percent) {
    return '$tokens · $percent';
  }

  @override
  String get contextPartUnder1 => '<1%';

  @override
  String get contextPartSystemPrompt => 'System prompt';

  @override
  String get contextPartTools => 'Tool definitions';

  @override
  String get contextPartRules => 'Rules';

  @override
  String get contextPartSkills => 'Skills list';

  @override
  String get contextPartMcp => 'MCP tools';

  @override
  String get contextPartSubagents => 'Sub-agents';

  @override
  String get contextPartMemory => 'Memory';

  @override
  String get contextPartConversation => 'Conversation';

  @override
  String get contextFree => 'Free';

  @override
  String get contextFilesTitle => 'Context files';

  @override
  String get contextFileTruncated => 'Cut short: longer than the file limit';

  @override
  String get contextFileFlagged =>
      'Loaded, but it looks like a prompt injection. Check the file';

  @override
  String get contextFileShadowed =>
      'Not loaded: a file of higher priority is used';

  @override
  String get contextFileBlocked =>
      'Not loaded: blocked by the prompt-injection check';

  @override
  String get contextFileEmpty => 'Not loaded: the file is empty';

  @override
  String get contextFileUnreadable => 'Not loaded: the file cannot be read';

  @override
  String get contextFileSuppressed => 'Not loaded: outside the bot\'s folder';

  @override
  String get contextFileNotLoaded => 'Not loaded';

  @override
  String get contextTotalsTitle => 'This conversation';

  @override
  String get contextReasoning => 'Reasoning tokens';

  @override
  String get contextCacheHits => 'Prompt cache hits';

  @override
  String get contextCalls => 'Model calls';

  @override
  String get contextCompactions => 'Compactions';

  @override
  String contextBreakdownFailed(String reason) {
    return 'Could not load the breakdown. $reason';
  }

  @override
  String get contextRetry => 'Try again';

  @override
  String get chatMoreActions => 'More actions';

  @override
  String get composerModelAndEffort => 'Model and effort';

  @override
  String get chatToolStateDone => 'Done';

  @override
  String get sidebarReconnect => 'Reconnect';

  @override
  String get spinnerLoading => 'Loading';

  @override
  String botCronRunNowNamed(String name) {
    return 'Run $name now';
  }

  @override
  String botCronDeleteNamed(String name) {
    return 'Delete $name';
  }

  @override
  String botCronScheduleAndNext(String schedule, String next) {
    return '$schedule · $next';
  }

  @override
  String botCronWeekdayRange(String first, String last) {
    return '$first–$last';
  }

  @override
  String get botCronListSeparator => ', ';

  @override
  String get botCronStatusError => 'Failed';

  @override
  String get botCronStatusDeliveryFailed => 'Delivery failed';

  @override
  String get sidebarRailLoadFailed => 'Could not load bots. Retry';

  @override
  String get chatMessageActionsLabel => 'Message actions';

  @override
  String get chatRecordButton => 'Record voice message';

  @override
  String get chatRecordStop => 'Stop and send recording';

  @override
  String get chatRecordingCancel => 'Release to cancel';

  @override
  String get chatRecordingTap => 'Recording… tap the mic to send';

  @override
  String chatMoreActionsHidden(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'More actions, $count hidden messages',
      one: 'More actions, 1 hidden message',
    );
    return '$_temp0';
  }

  @override
  String get chatOpenFailedTitle => 'Could not open this chat';

  @override
  String get chatOpenFailedBody =>
      'Check the connection to the gateway, then try again.';

  @override
  String get chatSending => 'Sending';

  @override
  String get mediaVideoFailed => 'Video unavailable';

  @override
  String get mediaAudioFailed => 'Audio unavailable';

  @override
  String get mediaSeek => 'Seek';

  @override
  String mediaViewerCounter(int index, int count) {
    return '$index / $count';
  }

  @override
  String mediaAudioTime(String position, String duration) {
    return '$position / $duration';
  }

  @override
  String chatToolDuration(String seconds) {
    return '${seconds}s';
  }

  @override
  String chatJoinDot(String first, String second) {
    return '$first · $second';
  }

  @override
  String get settingsGatewayUrlUserInfo =>
      'Remove the user name and password from the address and sign in below instead';

  @override
  String get settingsDiscardBody =>
      'The gateway settings you changed are not saved.';

  @override
  String get settingsPasswordShow => 'Show password';

  @override
  String get settingsPasswordHide => 'Hide password';

  @override
  String get settingsTokenShow => 'Show token';

  @override
  String get settingsTokenHide => 'Hide token';

  @override
  String get settingsTokenUse => 'Use this token';

  @override
  String get settingsAuthProviderSeparator => ', ';

  @override
  String get notificationQuestionSeparator => ' · ';

  @override
  String shareSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files were left out because they are over the limit',
      one: '1 file was left out because it is over the limit',
    );
    return '$_temp0';
  }

  @override
  String fileSizeB(String size) {
    return '$size B';
  }

  @override
  String fileSizeKB(String size) {
    return '$size KB';
  }

  @override
  String fileSizeMB(String size) {
    return '$size MB';
  }

  @override
  String fileSizeGB(String size) {
    return '$size GB';
  }

  @override
  String get connectGuideTitle => 'How to connect';

  @override
  String get connectGuideBody =>
      'Pomelu connects to Hermes Agent on your own computer. Do these steps one time.\n\n### 1. Install Hermes Agent\nInstall [Hermes Agent](https://hermes-agent.nousresearch.com/docs/getting-started/installation) 0.21.5 or newer on your computer. To update it:\n\n```\nhermes update\n```\n\n### 2. Set a username and password\nAdd these lines to `~/.hermes/.env` on the computer. Use your own username and a strong password:\n\n```\nHERMES_DASHBOARD_BASIC_AUTH_USERNAME=me\nHERMES_DASHBOARD_BASIC_AUTH_PASSWORD=a-strong-password\nHERMES_DASHBOARD_BASIC_AUTH_SECRET=paste-the-secret-here\n```\n\nTo make the secret, run:\n\n```\nopenssl rand -base64 32\n```\n\n### 3. Start the gateway\nRun this on the computer and keep it running:\n\n```\nhermes dashboard --host 0.0.0.0 --no-open\n```\n\n### 4. Find the address\n- **Same Wi-Fi:** `http://` + the computer\'s IP address + `:9119`, for example `http://192.168.1.20:9119`.\n- **Away from home:** use a private network such as [Tailscale](https://tailscale.com), or put the gateway behind `https://`.\n\n### 5. Connect the app\nIn Settings, type the address in **Gateway URL**. Sign in with the username and password. Tap **Test connection**, then **Save and connect**.\n\n### 6. Let your bots message you\nSo that your bots can message you first, also while the app is closed (\"message me every day at 7\"), install the Pomelu plugin on the computer, then restart Hermes:\n\n```\nhermes plugins install ateymoori/pomelu-hermes-plugin --enable\nhermes pomelu setup\n```\n\nThe phone then rings by push when a bot writes in its chat. Pomelu registers the phone by itself; keep **Notify me** on.\n\n### If it does not connect\n- **HTTP failed:** check the address. Make sure the computer is on and its firewall allows port 9119.\n- **WebSocket failed:** a proxy or tunnel in front of the gateway must allow WebSockets.\n- **Gateway too old:** run `hermes update` on the computer.';

  @override
  String get botEdit => 'Edit bot';

  @override
  String get botEditName => 'Name';

  @override
  String botEditProfileId(String id) {
    return 'Profile: $id';
  }

  @override
  String get botEditChoosePhoto => 'Choose photo';

  @override
  String get botEditRemovePhoto => 'Remove photo';

  @override
  String get botEditPhotoFailed => 'Could not open your photos';

  @override
  String get botEditPhotoTooLarge =>
      'This photo is too large. Choose a smaller one.';

  @override
  String get botEditSave => 'Save';

  @override
  String botEditSaveFailed(String message) {
    return 'Could not save: $message';
  }

  @override
  String get botEditDiscardBody => 'The changes to this bot are not saved.';

  @override
  String get botDelete => 'Delete bot';

  @override
  String botDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get botDeleteBody =>
      'This deletes the bot and its chats, memory and files on the gateway. You cannot undo this.';

  @override
  String get botNew => 'New bot';

  @override
  String get botNewCreate => 'Create';

  @override
  String botNewFailed(String message) {
    return 'Could not create the bot: $message';
  }

  @override
  String get botEditCharacters => 'Characters';

  @override
  String botEditCharacter(int number) {
    return 'Character $number';
  }

  @override
  String get botEditPicture => 'Picture';

  @override
  String get screenAction => 'Screen';

  @override
  String get screenActionHeld => 'Screen: a person has control';

  @override
  String screenLabel(String name) {
    return '$name\'s screen';
  }

  @override
  String get screenBotInControl => 'Bot in control';

  @override
  String get screenYouInControl => 'You are in control';

  @override
  String get screenOtherInControl => 'Another viewer in control';

  @override
  String get screenConnecting => 'Connecting…';

  @override
  String get screenOff => 'Screen is off';

  @override
  String screenOffMessage(String name) {
    return 'Start it to watch what $name does.';
  }

  @override
  String get screenStart => 'Start screen';

  @override
  String get screenCannotStart => 'The screen cannot start';

  @override
  String get screenNone => 'No screen';

  @override
  String get screenNoneMessage => 'This bot\'s gateway has no screen.';

  @override
  String get screenEnded => 'Stream ended';

  @override
  String get screenEndedMessage => 'The picture from the screen stopped.';

  @override
  String get screenReconnect => 'Reconnect';

  @override
  String get screenTakeOver => 'Take over';

  @override
  String get screenHandBack => 'Hand back';

  @override
  String screenGiveBack(String name) {
    return 'Give control to $name';
  }

  @override
  String screenGiveBackTitle(String name) {
    return 'Give control back to $name?';
  }

  @override
  String screenGiveBackBody(String name) {
    return 'Someone else has control now, on another device or in this app before it lost its connection. $name can use its screen again.';
  }

  @override
  String get screenTakeOverTitle => 'Take over from the other viewer?';

  @override
  String screenTakeOverBody(String name) {
    return 'Someone else has control of $name\'s screen. They can only watch once you take over.';
  }

  @override
  String get screenControlTaken =>
      'Another viewer took control. You are watching.';

  @override
  String screenStartFailed(String message) {
    return 'Could not start the screen: $message';
  }

  @override
  String screenTakeOverFailed(String message) {
    return 'Could not take over: $message';
  }

  @override
  String screenHandBackFailed(String message) {
    return 'Could not hand back: $message';
  }

  @override
  String get screenFit => 'Whole screen';

  @override
  String get screenFill => 'Fill screen';

  @override
  String get screenKeyboard => 'Keyboard';

  @override
  String get screenDrag => 'Drag and drop';

  @override
  String get screenDragCancel => 'Cancel drag';

  @override
  String get screenDragPick => 'Tap what to drag';

  @override
  String get screenDragDrop => 'Tap where to drop it';

  @override
  String get screenTyping => 'Type on the bot\'s screen';

  @override
  String get screenPaste => 'Paste';

  @override
  String get screenPasteEmpty => 'Nothing to paste';

  @override
  String get screenPasteTooLong => 'The clipboard is too long for the screen.';

  @override
  String get screenPasteOnClipboard =>
      'Too long to type. It is on the screen\'s clipboard: paste it there.';

  @override
  String get screenKeyEscape => 'Escape';

  @override
  String get screenKeyEscapeCap => 'Esc';

  @override
  String get screenKeyControlCap => 'Ctrl';

  @override
  String get screenKeyTab => 'Tab';

  @override
  String get screenKeyControl => 'Control';

  @override
  String get screenKeyAlt => 'Alt';

  @override
  String get screenKeyLeft => 'Left arrow';

  @override
  String get screenKeyUp => 'Up arrow';

  @override
  String get screenKeyRight => 'Right arrow';

  @override
  String get screenKeyDown => 'Down arrow';

  @override
  String get screenKeyboardHide => 'Hide keyboard';
}
