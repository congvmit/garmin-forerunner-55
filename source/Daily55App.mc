import Toybox.Application;

class Daily55App extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        return [new Daily55View()];
    }
}
