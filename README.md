# Notes

## iTerm2

To setup to load the preference file committed in this repo:
- GUI: Settings -> General -> Preferences
    - Check "Load preferences from a custom folder or URL"
    - Set the custom folder to `~/.config/iterm2`
- CLI:
```bash
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -int 1
defaults write com.googlecode.iterm2 PrefsCustomFolder /Users/qyriad/.config/iterm2
```
