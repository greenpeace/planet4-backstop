module.exports = async function (page, scenario, vp) {

    console.log('-------onBefore script-------');

    page.on('load', () => {
        console.log('-----Page loading-----');

        // Remove happypoint from the page
        // to avoid timeout issues
        const happy = await page.evaluate(() => {
            const happy_point = document.getElementById('happy-point');
            console.log('Removing happypoint');
            happy_point.parentNode.removeChild(happy_point);
        });
        console.log(happy);
    });

    page.once('load', () => {
        console.log('-----Page loaded!-----');
    });

};
