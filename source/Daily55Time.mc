module Daily55Time {
    function clockText(hour, minute, is24Hour) {
        var displayHour = hour;
        if (!is24Hour) {
            displayHour = hour % 12;
            if (displayHour == 0) {
                displayHour = 12;
            }
        }
        return displayHour.format("%02d") + ":" + minute.format("%02d");
    }

    function periodText(hour, is24Hour) {
        return is24Hour ? "" : (hour < 12 ? "AM" : "PM");
    }
}
