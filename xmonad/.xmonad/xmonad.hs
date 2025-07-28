import XMonad
import Control.Monad (when)
import Data.List (isInfixOf)
import Debug.Trace
import XMonad.Actions.CycleWS (toggleWS)
import XMonad.Actions.WindowGo -- needed for runOrRaise
-- import XMonad.Actions.Navigation2D
import XMonad.Actions.GridSelect
import XMonad.Actions.FocusNth
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops as E
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Layout.Accordion
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (spawnPipe, safeSpawn)
import XMonad.Util.SpawnOnce
import qualified XMonad.StackSet as W
import qualified XMonad.Util.NamedWindows as NW
import System.IO (hPutStrLn)


myModMask = mod1Mask
myTerminal = "st"
myTerminalClass = "st-256color"
myBrowser = "thorium-browser"
myBrowserProgramName = "thorium"
myBrowserClass = "Thorium-browser"
myFont = "xft:Liberation Mono:size=10"
myGSFont = "xft:Liberation Sans:style=bold:size=14"


main = do
    xmproc <- spawnPipe "xmobar"
    -- xmonad $ withNavigation2DConfig def $ withUrgencyHook MyUrgencyHook $ ewmh $ docks def
    xmonad $ withUrgencyHook MyUrgencyHook $ ewmh $ docks def
        { modMask               = myModMask
        , terminal              = myTerminal
        , borderWidth           = 1
        , normalBorderColor     = "#000000"
        , focusedBorderColor    = "#b8e986"
        , manageHook            = namedScratchpadManageHook myScratchpads
                                    <+> myManageHook
                                    <+> manageHook def
        , workspaces            = myWorkspaces
        , layoutHook            = myLayout
        , handleEventHook       = handleEventHook def <+> E.fullscreenEventHook
        , logHook               = dynamicLogWithPP xmobarPP
                                    { ppOutput = hPutStrLn xmproc
                                    , ppLayout = const "" -- hide layout name
                                    } >> workspaceHistoryHook
        , startupHook           = myStartupHook
        }
        `additionalKeysP`
        -- [ ("M-h", windowGo L False)
        -- , ("M-l", windowGo R False)
        -- , ("M-j", windowGo D False)
        -- , ("M-k", windowGo U False)
        [ ("M-f",   sendMessage ToggleStruts >> sendMessage ToggleLayout)
        , ("M-v",   namedScratchpadAction myScratchpads "term")
        , ("M-n",   namedScratchpadAction myScratchpads "notes")
        , ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
        , ("M-S-f", withFocused $ \w -> windows (W.float w (W.RationalRect 0.25 0.25 0.5 0.5)))

        , ("M-s",   goToSelected myGSConfigWindow)
        , ("M-S-s", bringSelected myGSConfigWindow)

        , ("M-u",   focusUrgent)

        , ("M-b",   runOrRaise myBrowser (className =? myBrowserClass))
        , ("M-r",   runOrRaise myTerminal (className =? myTerminalClass))
        , ("M-e",   runOrRaise "steam -silent steam://rungameid/444200" (className =? "steam_app_444200"))

        , ("M-C-c", runGridSelect myGSConfigFunction myConfigs)
        , ("M-C-l", runGridSelect myGSConfigFunction myLinks)
        , ("M-C-r", runGridSelect myGSConfigFunction myPrograms)
        , ("M-C-x", runGridSelect myGSConfigFunction mySystemActions)
        , ("M-C-0", runGridSelect myGSConfigFunction myCopyCommands)

        , ("M-`", toggleWS)

        , ("<F10>", spawn "thorium-browser --new-tab chat.openai.com")
        ]


myManageHook = composeAll
    [ className =? "steam_app_444200"   --> doShift "2:wotb"
    -- , className =? "steam"              --> doShift "9:steam"
    ]


myWorkspaces = ["1:work", "2:wotb", "3:internet", "4", "5", "6", "7", "8", "9:steam"]


myScratchpads = [ NS "term"       spawnTerm       findTerm    manageTerm
                , NS "notes"      spawnNotes      findNotes   manageTerm ]
    where
        spawnTerm       = myTerminal ++ " -n ScratchTerm"
        findTerm        = resource =? "ScratchTerm"
        manageTerm      = customFloating $ W.RationalRect 0.25 0.25 0.5 0.5
        spawnNotes      = myTerminal ++ " -n ScratchNotes"
        findNotes       = resource =? "ScratchNotes"


data MyUrgencyHook = MyUrgencyHook
instance UrgencyHook MyUrgencyHook where
    urgencyHook MyUrgencyHook w = do
        name <- NW.getName w
        let winName = show name
        when ("WoT Blitz" `isInfixOf` winName) $
            safeSpawn "notify-send" ["-u", "critical", "-t", "5000", "Steam is urgent"]


myLayout = smartBorders $ fullscreenFull $ avoidStruts $ toggleLayouts Full $ spacing 8 (
            Tall        1 (3/100) (1/2)
        ||| ThreeColMid 1 (3/100) (1/2)
        ||| Mirror (Tall 1 (3/100) (1/2))
        ||| Full
        ||| Accordion
    )


myStartupHook = do
    spawn "xset r rate 200 40"
    spawn "pgrep -x sxhkd || sxhkd &"
    spawn "nitrogen --restore"
    spawn "pgrep steam || steam -silent steam://rungameid/444200"
    spawn ("pgrep -x " ++ myTerminal ++ " || " ++ myTerminal)
    spawn ("pgrep -x " ++ myBrowserProgramName ++ " || " ++ myBrowser ++ " --new-tab chatgpt.com")


myGSConfigWindow :: GSConfig Window
myGSConfigWindow = def
    { gs_cellheight = 60
    , gs_cellwidth  = 200
    , gs_font       = myGSFont
    }


myGSConfigFunction :: GSConfig (X ())
myGSConfigFunction = (buildDefaultGSConfig tokyoNightStormColorizer)
    { gs_cellheight = 60
    , gs_cellwidth  = 200
    , gs_font       = myGSFont
    }


tokyoNightStormColorizer :: a -> Bool -> X (String, String)
tokyoNightStormColorizer _ isSelected =
    return $
        if isSelected
            then ("#ffbf00", "#1f2335")  -- Selected: brighter text, slightly lighter bg
            else ("#414868", "#cccccc")  -- Normal: muted text, base b


myLinks =
    [ ("ChatGPT",        spawn $ myBrowser ++ " --new-tab chatgpt.com")
    , ("YouTube",        spawn $ myBrowser ++ " --new-tab youtube.com")
    , ("Gmail",          spawn $ myBrowser ++ " --new-tab gmail.com")
    , ("Pull requests",  spawn $ myBrowser ++ " --new-tab https://github.com/microsoft/demikernel/pulls")
    , ("Github Actions", spawn $ myBrowser ++ " --new-tab https://github.com/microsoft/demikernel/actions")
    ]


myPrograms =
    [ ("Terminal",  spawn myTerminal)
    , ("Browser",   spawn myBrowser)
    , ("Blender",   spawn "blender")
    ]


myConfigs =
    [ ("Xmonad",    spawn (myTerminal ++ " -e nvim ~/.xmonad/xmonad.hs"))
    , ("xmobar",    spawn (myTerminal ++ " -e nvim ~/.xmobarrc"))
    , ("sxhkd",     spawn (myTerminal ++ " -e nvim ~/.config/sxhkd/sxhkdrc"))
    , ("neovim",    spawn (myTerminal ++ " -e nvim ~/.config/nvim/init.lua"))
    ]


mySystemActions =
    [ ("Restart Xmonad",    spawn "xmonad --restart")
    , ("Shutdown",          spawn "poweroff")
    , ("Reboot",            spawn "sudo reboot")
    , ("Suspend",           spawn "sudo systemctl suspend")
    ]


myCopyCommands =
    [ ("Xmonad errors", spawn "xmonad --recompile 2> ~/.errfile; cat ~/.errfile | xclip -selection clipboard; rm ~/.errfile")
    , ("Xmonad config", spawn "xclip -selection clipboard ~/.xmonad/xmonad.hs")
    ]


runGridSelect :: GSConfig (X ()) -> [(String, X ())] -> X ()
runGridSelect gsConfig actions =
    gridselect gsConfig actions >>= maybe (return ()) id
