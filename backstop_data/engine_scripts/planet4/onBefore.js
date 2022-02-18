module.exports = async function (page, scenario, vp) {

    console.log('-------onBefore script-------');

    page.once('load', () => {
        console.log('-----Page loaded!-----');
    });

};
