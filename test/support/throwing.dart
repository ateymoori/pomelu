/// Throws [error], whatever a test injected: an `Exception`, a typed
/// `HermesFailure`, or an `Error` such as `StateError` (a bug the code under
/// test must survive). A fake that holds "the failure to throw" as an `Object`
/// throws it through here, so `only_throw_errors` stays on for everything
/// else.
Never throwInjected(Object error) =>
    Error.throwWithStackTrace(error, StackTrace.current);
