# Add Optional Response Time Charts to Public Status Pages

## Overview

This PR adds the ability to optionally display response time (ping) charts on public status pages. Status page administrators can now control whether visitors see latency graphs for each monitor through a toggle setting.

## Features

- **Optional Response Time Charts**: Status pages can now display PingChart components showing response-time graphs for each monitor
- **Toggle Control**: Administrators can enable/disable this feature per status page via a toggle in the edit sidebar
- **Granular Control**: Each status page can independently show or hide response time charts
- **Backwards Compatible**: Existing status pages default to hiding charts (opt-in behavior)

## Changes Made

### Database

- **Migration**: `2025-11-03-0000-add-show-response-time.js`
  - Adds `show_response_time` boolean column to `status_page` table
  - Defaults to `false` to maintain backwards compatibility

### Frontend

#### `src/pages/StatusPage.vue`
- Added "Show Response Time" toggle switch in the edit sidebar
- Positioned after "Show Certificate Expiry" toggle
- Passes `showResponseTime` config to `PublicGroupList` component

#### `src/components/PublicGroupList.vue`
- Added `showResponseTime` prop (defaults to `false`)
- Conditionally renders `PingChart` component only when:
  - `showResponseTime` is `true` AND
  - Monitor type is not `'group'`
- Imported `PingChart` as an async component for code splitting

#### `src/components/PingChart.vue`
- Enhanced to work on public status pages (previously only worked in private dashboard)
- Falls back to `publicMonitorList` for monitor interval data when `monitorList` is unavailable
- Hides period selector dropdown on public status pages (only "recent" mode available)
- Automatically defaults to "recent" mode when websocket methods are not available
- Gracefully handles missing `getMonitorChartData` method

### Backend

#### `server/model/status_page.js`
- Added `showResponseTime` field to `toJSON()` method (for private API)
- Added `showResponseTime` field to `toPublicJSON()` method (for public API)

#### `server/model/monitor.js`
- Added `interval` field to `toPublicJSON()` method
- Allows PingChart to access monitor interval data on public status pages

#### `server/socket-handlers/status-page-socket-handler.js`
- Added `show_response_time` field to status page save handler
- Persists the toggle setting to database

## Usage

### For Status Page Administrators

1. Navigate to your status page (e.g., `/status/your-slug`)
2. Click "Edit Status Page" button
3. In the sidebar, find the "Show Response Time" toggle
4. Enable/disable the toggle as desired
5. Click "Save" to persist the change

### Behavior

- **Enabled**: Public visitors will see response time charts below each monitor's heartbeat bar
- **Disabled**: Charts are hidden (default behavior for existing status pages)

## Technical Details

### Chart Data Source

- **Recent Mode** (only available on public pages): Uses heartbeat data from `/api/status-page/heartbeat/:slug` endpoint
- **Historical Periods** (3h, 6h, 24h, 1w): Not available on public status pages as they require websocket connection

### Data Requirements

The PingChart component requires:
- Monitor `interval` data (now included in public monitor JSON)
- Heartbeat list data (available via status page heartbeat API)
- Monitor ID to fetch the correct data

### Performance Considerations

- Charts are lazy-loaded using `defineAsyncComponent()` to reduce initial bundle size
- Chart rendering is conditional based on the toggle setting
- Only renders for non-group monitors

## Migration Notes

### Automatic Migration

The database migration runs automatically when the server starts. No manual intervention required.

### Existing Status Pages

- All existing status pages will have `show_response_time` set to `false`
- Charts will be hidden by default
- Administrators must opt-in to enable charts per status page

## Files Changed

### New Files
- `db/knex_migrations/2025-11-03-0000-add-show-response-time.js`

### Modified Files
- `src/pages/StatusPage.vue`
- `src/components/PublicGroupList.vue`
- `src/components/PingChart.vue`
- `server/model/status_page.js`
- `server/model/monitor.js`
- `server/socket-handlers/status-page-socket-handler.js`

## Testing

### Manual Testing Steps

1. **Enable Toggle**:
   - Edit a status page
   - Enable "Show Response Time" toggle
   - Save and verify charts appear on public page

2. **Disable Toggle**:
   - Edit status page
   - Disable "Show Response Time" toggle
   - Save and verify charts are hidden

3. **Multiple Status Pages**:
   - Create/verify multiple status pages
   - Enable toggle on one, disable on another
   - Verify each page shows/hides charts independently

4. **Group Monitors**:
   - Add a group-type monitor to a status page
   - Verify no chart appears for group monitors (expected behavior)

### Browser Compatibility

- Modern browsers with ES6+ support
- Chart.js rendering requires Canvas support

## Screenshots

### Edit Sidebar
- Toggle located in status page edit sidebar
- Positioned after "Show Certificate Expiry" option

### Public Status Page
- Charts appear below monitor heartbeat bars when enabled
- Shows response time graphs with "Recent" period selector

## Future Enhancements

Potential improvements:
- Add option to show/hide charts per monitor (not just globally)
- Support historical chart periods on public pages via REST API
- Add chart customization options (time range, display format)

## Related Issues

This feature addresses the limitation where response time charts were only available in the private dashboard (`Details.vue`) but not on public status pages (`StatusPage.vue`).

## Notes

- The feature is fully backwards compatible
- No breaking changes to existing APIs
- Database migration is safe to run on existing installations

