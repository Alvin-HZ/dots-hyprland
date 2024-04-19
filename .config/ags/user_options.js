
let userConfigOptions = {
    // General stuff
    'ai': {
        'defaultGPTProvider': "openai",
        'defaultTemperature': 0.9,
        'writingCursor': " ...", // Warning: Using weird characters can mess up Markdown rendering
    },
    'animations': {
        'durationSmall': 110,
        'durationLarge': 180,
    },
    'apps': {
        'imageViewer': "loupe",
        'terminal': "foot", // This is only for shell actions
    },
    'battery': {
        'low': 20,
        'critical': 10,
    },
    'music': {
        'preferredPlayer': "plasma-browser-integration",
    },
    'onScreenKeyboard': {
        'layout': "qwerty_full", // See modules/onscreenkeyboard/onscreenkeyboard.js for available layouts
    },
    'overview': {
        'scale': 0.12, // Relative to screen size
        'numOfRows': 1,
        'numOfCols': 5,
        'wsNumScale': 0.09,
        'wsNumMarginScale': 0.07,
    },
    'sidebar': {
        'imageColumns': 2,
    },
    'search': {
        'engineBaseUrl': "https://www.bing.com/search?q=",
        'excludedSites': ["quora.com"],
    },
    'time': {
        // See https://docs.gtk.org/glib/method.DateTime.format.html
        // Here's the 12h format: "%I:%M%P"
        // For seconds, add "%S" and set interval to 1000
        'format': "%H:%M",
        'interval': 5000,
        'dateFormatLong': "%A, %m/%d", // On bar
        'dateInterval': 5000,
        'dateFormat': "%m/%d", // On notif time
    },
    'weather': {
        'city': "",
    },
    'workspaces': {
        'shown': 10,
    },
    // Longer stuff
    'icons': {
        // Find the window's icon by its class with levenshteinDistance
        // The file names are processed at startup, so if there
        // are too many files in the search path it'll affect performance
        // Example: ['/usr/share/icons/Tela-nord/scalable/apps']
        'searchPaths': [''],

        substitutions: {
            'code-url-handler': "visual-studio-code",
            'Code': "visual-studio-code",
            'GitHub Desktop': "github-desktop",
            'Minecraft* 1.20.1': "minecraft",
            'gnome-tweaks': "org.gnome.tweaks",
            'pavucontrol-qt': "pavucontrol",
            'wps': "wps-office2019-kprometheus",
            'wpsoffice': "wps-office2019-kprometheus",
            '': "image-missing",
        }
    },
    'keybinds': { 
        'sidebar': {
            'pin': "Ctrl+p",
            'nextTab': "Ctrl+Page_Down",
            'prevTab': "Ctrl+Page_Up",
        },
    },
    'dock': {
        'enabled': true,
        'hiddenThickness': 5,
        'pinnedApps': ['brave','foot'],
        'layer': 'top',
        'monitorExclusivity': true, // Dock will move to other monitor along with focus if enabled
        'searchPinnedAppIcons': false, // Try to search for the correct icon if the app class isn't an icon name
        'trigger': [], // client_added, client_move, workspace_active, client_active
        // Automatically hide dock after `interval` ms since trigger
        'autoHide': [
            {
                'trigger': 'client-added',
                'interval': 500,
            },
            {
                'trigger': 'client-removed',
                'interval': 500,
            },
        ],
    },
}

export default userConfigOptions;
