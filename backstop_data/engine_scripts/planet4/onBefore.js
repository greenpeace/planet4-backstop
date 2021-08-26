module.exports = async function (page, scenario, vp) {

    console.log('-------onBefore script-------');

    page.on('load', () => {
        console.log('-----Page loading-----');

        // Remove happypoint from the page
        // to avoid timeout issues
        page.$eval('#happy-point', (happypoint) => {
            console.log('Removing happypoint');
            happypoint.parentNode.removeChild(happypoint);
        });
    });

    page.once('load', () => {
        console.log('-----Page loaded!-----');
    });

};
