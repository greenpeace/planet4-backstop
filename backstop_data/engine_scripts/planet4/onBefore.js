module.exports = async function (page, scenario, vp) {

    console.log('-------onBefore script-------');

    // Add event handler for DOMContentLoaded event using puppeteer api.
    page.on('domcontentloaded', async () => {

        // Log DOMContentLoaded event.
        console.log('DOMContentLoaded');

        // Run snippet on DOMContentLoaded.
        // 1. Find iframes.
        // 2. if iframes have youtube as src set sandbox attribute to iframe
        //    to stop youtube scripts from running.
        page.evaluate(() => {
            console.log('search for iframes');
            let iframes = document.querySelectorAll('iframe');
            iframes.forEach((iframe) => {
                console.log('iframe');
                if (iframe.src.match(/^(http(s)?:\/\/)?((w){3}.)?youtu(be|.be)?(-nocookie)?(\.com)?\/.+/) !== null) {
                    iframe.sandbox.add('allow-forms');
                    console.log(iframe.src);
                }
            });
        });
    });

    // Add handler for every document that is created.
    //
    // From puppeteer documentation:
    // The function is invoked after the document was created but before any of its scripts were run.
    // This is useful to amend the JavaScript environment
    page.evaluateOnNewDocument(async (scenario) => {
        console.log('----------evaluateOnNewDocument------------');

        document.addEventListener('readystatechange', () => {
            console.log('readyState:' + document.readyState);
        });


        console.log('document location');
        console.log(document.location.href);
        if (document.location.href === scenario.url) {

            // Add event handler for DOMContentLoaded event.
            document.addEventListener('DOMContentLoaded', () => {

                // Search for carousel header block using the wrapper element id.
                var element = document.getElementById("carousel-wrapper-header");

                //If carousel header element exists in the DOM, remove data-carousel-autoplay attribute to prevent autoplau.
                if (typeof (element) != 'undefined' && element != null) {
                    console.log('found carousel header block');
                    element.removeAttribute('data-carousel-autoplay');
                }
                console.log('DOMContentLoaded');
            });
        }
    }, scenario);


    page.once('load', () => {
        console.log('-----Page loaded!-----');
    });

};
