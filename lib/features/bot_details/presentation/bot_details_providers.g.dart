// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bot_details_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read each time the sheet opens: cheap, and the dashboard may change them.

@ProviderFor(botSkills)
final botSkillsProvider = BotSkillsFamily._();

/// Read each time the sheet opens: cheap, and the dashboard may change them.

final class BotSkillsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BotSkill>>,
          List<BotSkill>,
          FutureOr<List<BotSkill>>
        >
    with $FutureModifier<List<BotSkill>>, $FutureProvider<List<BotSkill>> {
  /// Read each time the sheet opens: cheap, and the dashboard may change them.
  BotSkillsProvider._({
    required BotSkillsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botSkillsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botSkillsHash();

  @override
  String toString() {
    return r'botSkillsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BotSkill>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BotSkill>> create(Ref ref) {
    final argument = this.argument as String;
    return botSkills(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BotSkillsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botSkillsHash() => r'1c5780625a9fc090f30d5ca2667a2d0883132de2';

/// Read each time the sheet opens: cheap, and the dashboard may change them.

final class BotSkillsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BotSkill>>, String> {
  BotSkillsFamily._()
    : super(
        retry: null,
        name: r'botSkillsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Read each time the sheet opens: cheap, and the dashboard may change them.

  BotSkillsProvider call(String profile) =>
      BotSkillsProvider._(argument: profile, from: this);

  @override
  String toString() => r'botSkillsProvider';
}

@ProviderFor(botToolsets)
final botToolsetsProvider = BotToolsetsFamily._();

final class BotToolsetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<BotToolset>>,
          List<BotToolset>,
          FutureOr<List<BotToolset>>
        >
    with $FutureModifier<List<BotToolset>>, $FutureProvider<List<BotToolset>> {
  BotToolsetsProvider._({
    required BotToolsetsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botToolsetsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botToolsetsHash();

  @override
  String toString() {
    return r'botToolsetsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<BotToolset>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<BotToolset>> create(Ref ref) {
    final argument = this.argument as String;
    return botToolsets(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BotToolsetsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botToolsetsHash() => r'e50ba626d317727f5e7455f0638345b5ebe8001b';

final class BotToolsetsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<BotToolset>>, String> {
  BotToolsetsFamily._()
    : super(
        retry: null,
        name: r'botToolsetsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BotToolsetsProvider call(String profile) =>
      BotToolsetsProvider._(argument: profile, from: this);

  @override
  String toString() => r'botToolsetsProvider';
}

/// `SOUL.md`; invalidated after a save.

@ProviderFor(botSoul)
final botSoulProvider = BotSoulFamily._();

/// `SOUL.md`; invalidated after a save.

final class BotSoulProvider
    extends $FunctionalProvider<AsyncValue<BotSoul>, BotSoul, FutureOr<BotSoul>>
    with $FutureModifier<BotSoul>, $FutureProvider<BotSoul> {
  /// `SOUL.md`; invalidated after a save.
  BotSoulProvider._({
    required BotSoulFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botSoulProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botSoulHash();

  @override
  String toString() {
    return r'botSoulProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BotSoul> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<BotSoul> create(Ref ref) {
    final argument = this.argument as String;
    return botSoul(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BotSoulProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botSoulHash() => r'11067e8f48649268069e6d6b50f4593e812b560f';

/// `SOUL.md`; invalidated after a save.

final class BotSoulFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BotSoul>, String> {
  BotSoulFamily._()
    : super(
        retry: null,
        name: r'botSoulProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// `SOUL.md`; invalidated after a save.

  BotSoulProvider call(String profile) =>
      BotSoulProvider._(argument: profile, from: this);

  @override
  String toString() => r'botSoulProvider';
}

/// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
/// the failure after one that did not go through.

@ProviderFor(SoulSave)
final soulSaveProvider = SoulSaveFamily._();

/// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
/// the failure after one that did not go through.
final class SoulSaveProvider
    extends $NotifierProvider<SoulSave, AsyncValue<void>> {
  /// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
  /// the failure after one that did not go through.
  SoulSaveProvider._({
    required SoulSaveFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'soulSaveProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$soulSaveHash();

  @override
  String toString() {
    return r'soulSaveProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SoulSave create() => SoulSave();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SoulSaveProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$soulSaveHash() => r'8a1ceb8000ef5a0d393e7a77e41c41cf905a0bcf';

/// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
/// the failure after one that did not go through.

final class SoulSaveFamily extends $Family
    with
        $ClassFamilyOverride<
          SoulSave,
          AsyncValue<void>,
          AsyncValue<void>,
          AsyncValue<void>,
          String
        > {
  SoulSaveFamily._()
    : super(
        retry: null,
        name: r'soulSaveProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
  /// the failure after one that did not go through.

  SoulSaveProvider call(String profile) =>
      SoulSaveProvider._(argument: profile, from: this);

  @override
  String toString() => r'soulSaveProvider';
}

/// A save of [profile]'s `SOUL.md` from the editor: loading while it runs,
/// the failure after one that did not go through.

abstract class _$SoulSave extends $Notifier<AsyncValue<void>> {
  late final _$args = ref.$arg as String;
  String get profile => _$args;

  AsyncValue<void> build(String profile);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The jobs as the gateway last said; their actions live in [CronJobActions].

@ProviderFor(BotCronJobs)
final botCronJobsProvider = BotCronJobsFamily._();

/// The jobs as the gateway last said; their actions live in [CronJobActions].
final class BotCronJobsProvider
    extends $AsyncNotifierProvider<BotCronJobs, List<BotCronJob>> {
  /// The jobs as the gateway last said; their actions live in [CronJobActions].
  BotCronJobsProvider._({
    required BotCronJobsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'botCronJobsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$botCronJobsHash();

  @override
  String toString() {
    return r'botCronJobsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BotCronJobs create() => BotCronJobs();

  @override
  bool operator ==(Object other) {
    return other is BotCronJobsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$botCronJobsHash() => r'af65994bdc4318409ae0085345bbac3b93a694ea';

/// The jobs as the gateway last said; their actions live in [CronJobActions].

final class BotCronJobsFamily extends $Family
    with
        $ClassFamilyOverride<
          BotCronJobs,
          AsyncValue<List<BotCronJob>>,
          List<BotCronJob>,
          FutureOr<List<BotCronJob>>,
          String
        > {
  BotCronJobsFamily._()
    : super(
        retry: null,
        name: r'botCronJobsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The jobs as the gateway last said; their actions live in [CronJobActions].

  BotCronJobsProvider call(String profile) =>
      BotCronJobsProvider._(argument: profile, from: this);

  @override
  String toString() => r'botCronJobsProvider';
}

/// The jobs as the gateway last said; their actions live in [CronJobActions].

abstract class _$BotCronJobs extends $AsyncNotifier<List<BotCronJob>> {
  late final _$args = ref.$arg as String;
  String get profile => _$args;

  FutureOr<List<BotCronJob>> build(String profile);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BotCronJob>>, List<BotCronJob>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BotCronJob>>, List<BotCronJob>>,
              AsyncValue<List<BotCronJob>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
/// minutes and the tab can close and open meanwhile, and the job stays busy,
/// so no second run starts. The list changes only from the gateway's answer.

@ProviderFor(CronJobActions)
final cronJobActionsProvider = CronJobActionsFamily._();

/// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
/// minutes and the tab can close and open meanwhile, and the job stays busy,
/// so no second run starts. The list changes only from the gateway's answer.
final class CronJobActionsProvider
    extends $NotifierProvider<CronJobActions, CronJobActivity> {
  /// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
  /// minutes and the tab can close and open meanwhile, and the job stays busy,
  /// so no second run starts. The list changes only from the gateway's answer.
  CronJobActionsProvider._({
    required CronJobActionsFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'cronJobActionsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$cronJobActionsHash();

  @override
  String toString() {
    return r'cronJobActionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CronJobActions create() => CronJobActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CronJobActivity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CronJobActivity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CronJobActionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$cronJobActionsHash() => r'f41d4d9f22f299ebf00171c99c9ce85a220d5e05';

/// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
/// minutes and the tab can close and open meanwhile, and the job stays busy,
/// so no second run starts. The list changes only from the gateway's answer.

final class CronJobActionsFamily extends $Family
    with
        $ClassFamilyOverride<
          CronJobActions,
          CronJobActivity,
          CronJobActivity,
          CronJobActivity,
          (String, String)
        > {
  CronJobActionsFamily._()
    : super(
        retry: null,
        name: r'cronJobActionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
  /// minutes and the tab can close and open meanwhile, and the job stays busy,
  /// so no second run starts. The list changes only from the gateway's answer.

  CronJobActionsProvider call(String profile, String jobId) =>
      CronJobActionsProvider._(argument: (profile, jobId), from: this);

  @override
  String toString() => r'cronJobActionsProvider';
}

/// Pause, resume, run now and delete of job [jobId]. Kept alive: a run takes
/// minutes and the tab can close and open meanwhile, and the job stays busy,
/// so no second run starts. The list changes only from the gateway's answer.

abstract class _$CronJobActions extends $Notifier<CronJobActivity> {
  late final _$args = ref.$arg as (String, String);
  String get profile => _$args.$1;
  String get jobId => _$args.$2;

  CronJobActivity build(String profile, String jobId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CronJobActivity, CronJobActivity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CronJobActivity, CronJobActivity>,
              CronJobActivity,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
