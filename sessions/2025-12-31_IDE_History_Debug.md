# Session Log: Antigravity IDE History Debugging
**Date:** 2025-12-31
**Topic:** Troubleshooting missing conversation history in IDE UI.

## Context
The IDE fails to display past conversations in the UI, despite the underlying data files existing. The user suspects the software quality is poor ("made by Google").

## Investigation Findings
We identified three fragmented configuration directories:

1.  **`/home/lune/.gemini/antigravity/`** (Agent Data)
    *   Contains `conversations/*.pb`. **History data IS present here.**
    *   Contains `brain/` (artifacts) and `scratch/`.
    *   This is the "source of truth" for the AI's memory.

2.  **`/home/lune/.config/Antigravity/`** (Electron/App Data)
    *   Standard Electron app config.
    *   Contained a `code.lock` file, indicating a potential improper shutdown or stale lock.
    *   Stores `Cookies`, `Preferences`, `Local Storage`.

3.  **`/home/lune/.antigravity/`** (Extensions)
    *   Contains `extensions/` and `argv.json`.

## Actions Taken
1.  **Verified Data Integrity**: Confirmed `.pb` files in `~/.gemini/antigravity/conversations/` are not empty.
2.  **Cleared Lock File**: Removed `~/.config/Antigravity/code.lock` to force a clean state check on restart.
3.  **Fixed Permissions**: Ran `chmod -R u+rw` on the conversations directory to ensure the UI process has read access.

## Next Steps (If Issue Persists)
If the UI still shows empty history after restart:

1.  **Check Internal Database**: The Electron app likely uses LevelDB/IndexedDB in `~/.config/Antigravity/Local Storage/` or `Session Storage/`. It might have a corrupted index that is out of sync with the `.pb` files.
    *   *Try*: Rename/backup `~/.config/Antigravity/` to force the IDE to recreate the app state (this will lose cookies/local settings but might force a re-scan of history).
2.  **Logs**: Check `~/.config/Antigravity/logs/` or run the IDE from terminal to see stderr output.
3.  **Manual Restore**: If the UI refuses to listed them, we might need to manually "touch" the files or trigger a file watcher event.
