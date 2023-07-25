$(function () {
    // Proposed fix for #1686, pie chart tooltips not hiding when exiting to the left
    (function (H) {
        H.Chart.prototype.callbacks.push(function (chart) {
            H.addEvent(chart.container, 'mouseover', function (e) {
                var hoverSeries = chart.hoverSeries,
                    pointer = chart.pointer;
                if (hoverSeries && hoverSeries.options.tooltip.followPointer &&
                        !pointer.inClass(e.toElement || e.relatedTarget, 'highcharts-tracker')) {
                    pointer.reset();
                }
            });
        });
    }(Highcharts));
});