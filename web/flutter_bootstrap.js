{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
    },
    config: { 
        'hostElement': document.querySelector('#main-content'),
        canvasKitBaseUrl: "/canvaskit/",
        fontFallbackBaseUrl: "/assets/fallback_fonts/",
     },
    onEntrypointLoaded: async function (engineInitializer) {
        console.log('Flutter entrypoint loaded');
        const appRunner = await engineInitializer.initializeEngine();
        document.querySelector('#loading')?.classList.add('main_done');

        return appRunner.runApp();

        // NB: The code to remove the loading spinner is in the Flutter app.
        // This allows the Flutter app to control the timing of the spinner removal.

    }
});
