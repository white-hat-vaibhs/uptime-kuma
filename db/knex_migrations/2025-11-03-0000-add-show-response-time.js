exports.up = function (knex) {
    return knex.schema.alterTable("status_page", function (table) {
        table.boolean("show_response_time").defaultTo(false).notNullable();
    });
};

exports.down = function (knex) {
    return knex.schema.alterTable("status_page", function (table) {
        table.dropColumn("show_response_time");
    });
};

