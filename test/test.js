const pgp = require("pg-promise")();
const assert = require("assert");

test().catch(err => {
    console.error(`Got error`, err);
    process.exit(1);
});

async function test() {
    const db = pgp(`postgres://postgres:@postgres:5432/template_postgis?ssl=false&application_name=autotests`);
    const srid900913projections = await db.any('SELECT * FROM spatial_ref_sys WHERE srid = $1', [900913]);
    assert.strictEqual(srid900913projections.length, 1, "No 900913 projection when expecting one");
}
