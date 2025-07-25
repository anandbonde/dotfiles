import XMonad
import Control.Monad (when)
import Data.List (isInfixOf)
import Debug.Trace
import XMonad.Actions.WindowGo
import XMonad.Actions.Navigation2D
import XMonad.Actions.GridSelect
import XMonad.Actions.FocusNth
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops as E
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.UrgencyHook
import XMonad.Layout.Fullscreen
import XMonad.Layout.Spacing
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ToggleLayouts
import XMonad.Util.EZConfig (additionalKeys, additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (spawnPipe, safeSpawn)
import XMonad.Util.SpawnOnce
import qualified XMonad.StackSet as W
import qualified XMonad.Util.NamedWindows as NW
import System.IO (hPutStrLn)


myModMask = mod1Mask
myTerminal = "st"
myBrowser = "firefox"


main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ withNavigation2DConfig def $ withUrgencyHook MyUrgencyHook $ ewmh $ docks def
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
                                    }
        , startupHook           = myStartupHook
        }
        `additionalKeys`
        [ ((mod4Mask, xK_Return), spawn myTerminal)
        ]
        `additionalKeysP`
        [ ("M-f",   sendMessage ToggleStruts >> sendMessage ToggleLayout)
        , ("M-v",   namedScratchpadAction myScratchpads "term")
        , ("M-S-r", spawn "xmonad --recompile && xmonad --restart")
        , ("M-S-f", withFocused $ \w -> windows (W.float w (W.RationalRect 0.25 0.25 0.5 0.5)))
        , ("M-s",   goToSelected myGSConfig)
        , ("M-u",   focusUrgent)
        , ("M-h",   windowGo L False)
        , ("M-l",   windowGo R False)
        , ("M-j",   windowGo D False)
        , ("M-k",   windowGo U False)
        , ("M-b",   runOrRaise "firefox" (className =? "firefox_firefox"))
        , ("M-r",   runOrRaise "st" (className =? "st-256color"))
        , ("M-g",   runOrRaise "steam -silent steam://rungameid/444200" (className =? "steam_app_444200"))
        , ("M-n",   runGridActions)
        ]


myManageHook = composeAll
    [ className =? "steam_app_444200"   --> doShift "2:wotb"
    , className =? "steam"              --> doShift "9:steam"
    -- , className =? "firefox_firefox"    --> doShift "3:internet"
    ]


myWorkspaces :: [String]
myWorkspaces = ["1:work", "2:wotb", "3:internet", "4", "5", "6", "7", "8", "9:steam"]


myScratchpads = [ NS "term" spawnTerm findTerm manageTerm ]
    where
        -- st scratchpad
        spawnTerm   = myTerminal ++ " -n scratchpad"
        findTerm    = resource =? "scratchpad"
        manageTerm  = customFloating $ W.RationalRect 0.25 0.25 0.5 0.5


data MyUrgencyHook = MyUrgencyHook
instance UrgencyHook MyUrgencyHook where
    urgencyHook MyUrgencyHook w = do
        name <- NW.getName w
        let winName = show name
        when ("WoT Blitz" `isInfixOf` winName) $
            safeSpawn "notify-send" ["-u", "critical", "-t", "5000", "Steam is urgent"]


myLayout = fullscreenFull $ avoidStruts $ toggleLayouts Full $ spacing 0 (
            Tall        1 (3/100) (1/2)
        ||| ThreeColMid 1 (3/100) (1/2)
        ||| Mirror (Tall 1 (3/100) (1/2))
        ||| Full
    )


myStartupHook = do
    spawn "xset r rate 200 40"
    spawn "pgrep -x sxhkd || sxhkd &"
    spawn "nitrogen --restore"


myGSConfig = def
    { gs_cellheight = 30
    , gs_cellwidth  = 200
    , gs_font       = "xft:JetBrains Mono:size=10"
    }


myGridActions :: [(String, X ())]
myGridActions =
    [ ("Pull Requests",  spawn "firefox --new-tab 'https://github.com/microsoft/demikernel/pulls'")
    , ("Github Actions", spawn "firefox --new-tab 'https://github.com/microsoft/demikernel/actions'")
    , ("ChatGPT",        spawn "firefox --new-tab 'chatgpt.com'")
    ]


runGridActions :: X ()
runGridActions = gridselect defaultGSConfig myGridActions >>= maybe (return ()) id
