slate.log("loading .slate.js")

slate.eachScreen(function (so) {
    slate.log("s: " + so.id() +  " " + 
              "x: " + so.rect().x +      " " + 
              "y: " + so.rect().y +      " " + 
              "w: " + so.rect().width +  " " + 
              "h: " + so.rect().height + " " );
});

slate.configAll({
    'defaultToCurrentScreen': true,
    'windowHintsOrder': 'persist',
    'windowHintsShowIcons': true,
    'windowHintsIgnoreHiddenWindows': false,
    'windowHintsSpread': true,
    'switchShowTitles': true,
    });

var grid = slate.operation("grid", {
  "grids" : {
    "1920x1080" : {
      "width" : 4,
      "height" : 2,
    },
    "1680x1050" : {
      "width" : 4,
      "height" : 2,
    },
    "1440x900" : {
      "width" : 2,
      "height" : 2,
    }
  },
  "padding" : 5
});


/*
 * Run or raise a window for application `appName'.  
 *
 * If the application has more than one window cycle through all of them.
 *
 * `winFilter' is a predicate function to filter which of the application's
 * windows will be considered for cycling.  

 * If the application isn't running yet, attempt to start it by running the
 * runOp slate operation.
 */
function runOrRaise(appName, winFilter, runOp)
{
    var runningAppInstances = new Array();
    slate.eachApp(function (app) {
        slate.log("Checking '"+ app.name() +"' ...");
        // if (app.name() == appName) {
        //     runningAppInstances.push(app);
        // }
        var regex = new RegExp("GoToMeeting", "gi");
        if (regex.test(app.name())) {
            slate.log("Match! "+ app.name());
            runningAppInstances.push(app);
        }
    });
    slate.log("runningAppInstances:"+ runningAppInstances);
    var sortedAppInstances = _.sortBy(runningAppInstances, function(app) { return app.pid(); });
    var appWindows = new Array();
    if (sortedAppInstances.length > 0) {
        sortedAppInstances[0].eachWindow(function (win) { // TODO: collect all windows from ALL app instances.
            slate.log("sortedAppInstance win: "+ win);
            if (!winFilter || winFilter(win))  
                appWindows.push(win);
        });
    }

    if (appWindows.length > 0) {
        /* I can't rely on js object equality to test for OS Windows equality
         * (in fact, slate.window() != slate.window() always holds! ) and there
         * is no window identifier accessible from the js object afaik.  So the
         * workaround to find the currently focused window is to iterate through
         * all the windows looking for a matching title. It might be a good idea
         * to also require matching position and size but this seems to be good
         * enough for now.
         */
        slate.log("!"+ appWindows);
        appWindows = _.sortBy(appWindows, function (w) { return w.title();});
        var windowFocused = _.find(appWindows, function (w) {
            slate.log("windowFocused... does w.title "+ w.title() +" match slate.window.title "+ slate.window().title());
            return w.title() == slate.window().title();
        } );
        var currentWinIdx = _.indexOf(appWindows, windowFocused);
        var nextWin = appWindows[( currentWinIdx + 1) % appWindows.length];
        slate.log("nextWin.title: "+ nextWin.title());
        if (!nextWin.focus())
            slate.log("Failed to focus window " + nextWin.title());
    }
    else {
        slate.log("Running app " + appName);
        if (runOp) 
            runOp.run();
        else {
            // use the default openApp operation 
            openAppOperation(appName).run();
        }
    }
}

/*
 * Operations 
 * ==========
 */
var fullscreenOp = slate.operation("move", {
  "x" : "screenOriginX",
  "y" : "screenOriginY",
  "width" : "screenSizeX",
  "height" : "screenSizeY"
});

var firefoxRunOp = slate.operation("shell", {
    "command" : "/usr/bin/open -a Firefox --args --app /Users/leo/conkeror/application.ini",
    "wait" : false,
    "path" : "~/"
});

var emacsRunOp = slate.operation("shell", {
    "command" : "/usr/bin/open -a Emacs",
    "wait" : false,
    "path" : "~/"
});

function openAppOperation(appName) {
    return slate.operation("shell", {    
        "command" : "/usr/bin/open -a " + appName,
        "wait" : false,
        "path" : "~/"
    });
}

function allScreens() {
    var screens = new Array();
    slate.eachScreen(function (so) { screens.push(so); });
    return screens;
}

function screenInDirection(w, direction) {
    var screens = allScreens();
    var screensLeftToRight = _.sortBy(screens, function (s) { return   s.rect().x; });
    var screensRightToLeft = _.sortBy(screens, function (s) { return - s.rect().x; });
    var screensBottomToTop = _.sortBy(screens, function (s) { return - s.rect().y; });
    var screensTopToBottom = _.sortBy(screens, function (s) { return   s.rect().y; });

    switch (direction) {
    case "left":
        return _.find(screensRightToLeft, function (s) {return s.rect().x < w.screen().rect().x ;});
    case "right":
        return _.find(screensLeftToRight, function (s) {return s.rect().x > w.screen().rect().x ;});
    case "up":
        return _.find(screensBottomToTop, function (s) {return s.rect().y < w.screen().rect().y ;});
    case "down":
        return _.find(screensTopToBottom, function (s) {return s.rect().y > w.screen().rect().y ;});
    }
}

function throwInDirection(w, direction) {
    // direction is one of "left", "right", "up", "down"
    var nextScreen = screenInDirection(w, direction);
    slate.log("current screen: " + w.screen().id());
    if (nextScreen) {
        slate.log("next screen: " + nextScreen.id());
        w.doOperation(slate.operation("throw", { screen: nextScreen }));
    }
    else {
        slate.log("no more screens " + direction);
    }
}

var t= function (obj) { return true; }; // convenience match-all filter

slate.bind("r:z,alt", slate.operation("relaunch"));
slate.bind("g:z,alt", grid);
slate.bind("h:z,alt", slate.operation("hint"));
slate.bind("`:z,alt", fullscreenOp);
slate.bind("a:z,alt", function (w) { throwInDirection(w, "left"  ); });
slate.bind("d:z,alt", function (w) { throwInDirection(w, "right" ); });
slate.bind("w:z,alt", function (w) { throwInDirection(w, "up"    ); });
slate.bind("s:z,alt", function (w) { throwInDirection(w, "down"  ); });

var leftHalf = { "x": "screenOriginX",
                 "y": "screenOriginY",
                 "width": "screenSizeX/2", 
                 "height": "screenSizeY" };

var rightHalf= { "x": "screenOriginX + screenSizeX/2",
                 "y": "screenOriginY",
                 "width": "screenSizeX/2", 
                 "height": "screenSizeY" };

slate.bind(",:z,alt", slate.operation("move", leftHalf));
slate.bind(".:z,alt", slate.operation("move", rightHalf));

/*
 * Run or raise applications
 * =========================
 */
slate.bind("f:z,alt", function (w) { runOrRaise("Firefox", t); });
slate.bind("v:z,alt", function (w) { runOrRaise("Preview", t); });
slate.bind("e:z,alt", function (w) { 
    runOrRaise("Emacs", 
               // for some reason Emacs has two window objects per frame. One of
               // those windows has an empty title and always fails to focus, I
               // only care about the other -real- window, so I filter out those
               // virtual windows which have an empty title.
               function (w) { return w.title() != ""; },
               emacsRunOp); });

slate.log("done loading .slate.js")
