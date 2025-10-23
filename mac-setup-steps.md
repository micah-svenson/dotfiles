Steps I too to setup my Mac

- Install Obsidian
  - <https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.5/Obsidian-1.7.5.dmg>
- Install Dia Web Browser
  - Set Dia as default browser
- Install Chrome Web Browser
- Install Bitwarden App
  - Mac app store
- Turn dock hiding on
- install homebrew

  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
  - Put homebrew on $PATH

    ```
    echo >> /Users/micahsvenson/.zprofile

    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/micahsvenson/.zprofile

    eval "$(/opt/homebrew/bin/brew shellenv)"
    ```

- Install iterm2 `brew install --cask iterm2`
- Install oh my zsh
  - `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
- To remap the Caps Lock key to Escape on a Mac, you can do the following:
  1. Open System Preferences
  2. Click Keyboard
  3. Click Modifier Keys
  4. For Caps Lock (⇪) Key, select ⎋ Escape
  5. Click OK
- Install karabiner-elements (keyboard shortcuts etc)
  - `brew install --cask karabiner-elements`
- show 24 hour time on lock screen
- high power mode when on adapter power
- Create "Screenshots" folder in ICloud Drive
  - Change screenshots folder to the new icloud drive folder
- Karabiner:
  - In Settings > Login Items & Extensions Enable
    - Karabiner privileged and non privileged user agents and daemons
    - In extensions enaled karabiner hdd device manager
  - Hello There Where Are THEH HOUSE KEYS
- Install vscode
  - `brew install --cask visual-studio-code`
- Disable window tiling margins
  - Desktop & Dock> Tiled windows have margins
- Mission control: group windows by application
  - change mission controlShort cuts to use:
    - caps lock hyper key whichIs (ctrl+option+command+shift)
    - cap-hyper+k = mission control
    - cap-hyper+j = view all open windowsInApp
    - cap-hyper+h = desktop to the left
    - cap-hyper+l = desktop to the right
    - cap-hyper+1 = desktop 1
    - cap-hyper+2 = desktop 2
    - cap-hyper+n = open notification center
- Finder settings
  - add breadcrumb barAndStatus bar via the View tab
  - Set allViews to list
- OpenSCAD
  - `brew install --cask openscad@snapshot`
- Install chezmoi ( dotfile manager)
  - `brew install chezmoi`

TODOS:

- I want to add my iTerm2 config to dotfile
-
