## ❗ Important Announcements

<details><summary>Click here for more details:</summary>
</p>

**⚠️ Please Note: We do not accept all types of pull requests, and we want to ensure we don't waste your time. Before submitting, make sure you have read our pull request guidelines: [Pull Request Rules](https://github.com/louislam/uptime-kuma/blob/master/CONTRIBUTING.md#can-i-create-a-pull-request-for-uptime-kuma)**

### 🚫 Please Avoid Unnecessary Pinging of Maintainers

We kindly ask you to refrain from pinging maintainers unless absolutely necessary. Pings are for critical/urgent pull requests that require immediate attention.

</p>
</details>

## 📋 Overview

<!-- Provide a clear summary of the purpose and scope of this pull request:-->

- **What problem does this pull request address?**
  - Public status pages (`StatusPage.vue`) did not display response time (ping) charts, even though these charts existed in the private dashboard's monitor detail view (`Details.vue`). The `PingChart` component was never imported or used in the public status page context, leaving a gap in functionality for status page visitors who wanted to see latency trends.

- **What features or functionality does this pull request introduce or enhance?**
  - Adds an optional toggle control in the status page edit sidebar to show/hide response time charts on public status pages
  - Enables the `PingChart` component to work on public status pages by enhancing it to handle the public API context (using `publicMonitorList` instead of `monitorList`, hiding historical period selector, etc.)
  - Provides granular control per status page - each status page can independently enable or disable response time charts
  - Maintains backwards compatibility by defaulting to disabled (`false`) for all existing status pages

<!--
Please link any GitHub issues or tasks that this pull request addresses.
Use the appropriate issue numbers or links to enable auto-closing.
-->

- Relates to: Request for response time charts on public status pages
- Resolves: N/A (feature request)

## 🛠️ Type of change

<!-- Please select all options that apply -->

- [x] ✨ New feature (a non-breaking change that adds new functionality)
- [x] 🎨 User Interface (UI) updates
- [x] 📄 Documentation Update Required (the change requires updates to related documentation)
- [ ] 🐛 Bugfix (a non-breaking change that resolves an issue)
- [ ] ⚠️ Breaking change (a fix or feature that alters existing functionality in a way that could cause issues)
- [ ] 📄 New Documentation (addition of new documentation)
- [ ] 📄 Documentation Update (modification of existing documentation)
- [ ] 🔧 Other (please specify):

## 📄 Checklist

<!-- Please select all options that apply -->

- [x] 🔍 My code adheres to the style guidelines of this project.
- [x] 🦿 I have indicated where (if any) I used an LLM for the contributions
  - Used AI assistance for code implementation and review
- [x] ✅ I ran ESLint and other code linters for modified files.
- [x] 🛠️ I have reviewed and tested my code.
- [x] 📝 I have commented my code, especially in hard-to-understand areas (e.g., using JSDoc for methods).
- [x] ⚠️ My changes generate no new warnings.
- [ ] 🤖 My code needed automated testing. I have added them (this is an optional task).
  - Manual testing completed; automated tests can be added if needed
- [x] 📄 Documentation updates are included (if applicable).
  - PR documentation included in `PR_RESPONSE_TIME_CHART.md`
- [x] 🔒 I have considered potential security impacts and mitigated risks.
  - No security implications - only adds optional UI visibility control for existing data
- [x] 🧰 Dependency updates are listed and explained.
  - No new dependencies added; uses existing components and libraries
- [x] 📚 I have read and understood the [Pull Request guidelines](https://github.com/louislam/uptime-kuma/blob/master/CONTRIBUTING.md#recommended-pull-request-guideline).

## 📷 Screenshots or Visual Changes

<!--
If this pull request introduces visual changes, please provide the following details.
If not, remove this section.

Please upload the image directly here by pasting it or dragging and dropping.
Avoid using external image services as the image will be uploaded automatically.
-->

- **UI Modifications**: 
  - Added "Show Response Time" toggle switch in the status page edit sidebar (positioned after "Show Certificate Expiry")
  - Response time charts now appear below each monitor's heartbeat bar when enabled on public status pages

- **Before & After**: 

| Event              | Before                | After                |
| ------------------ | --------------------- | -------------------- |
| Status Page Edit Sidebar | No toggle for response time charts | "Show Response Time" toggle added |
| Public Status Page | Only uptime summaries and incident history visible | Response time charts displayed below monitors when enabled |
| Chart Visibility | Charts only in private dashboard (`Details.vue`) | Charts now available on public status pages (optional) |

## 🔧 Technical Details

### Database Changes
- **Migration**: `2025-11-03-0000-add-show-response-time.js`
  - Adds `show_response_time` boolean column to `status_page` table
  - Defaults to `false` for backwards compatibility
  - Runs automatically on server start

### Files Modified
- `src/pages/StatusPage.vue` - Added toggle UI and prop passing
- `src/components/PublicGroupList.vue` - Added conditional PingChart rendering
- `src/components/PingChart.vue` - Enhanced for public status page support
- `server/model/status_page.js` - Added `showResponseTime` to JSON methods
- `server/model/monitor.js` - Added `interval` to public JSON
- `server/socket-handlers/status-page-socket-handler.js` - Save handler update

### Files Created
- `db/knex_migrations/2025-11-03-0000-add-show-response-time.js` - Database migration
- `PR_RESPONSE_TIME_CHART.md` - Detailed documentation

## 🧪 Testing

### Manual Testing Performed
1. ✅ Enable toggle on status page → Charts appear on public page
2. ✅ Disable toggle on status page → Charts are hidden
3. ✅ Multiple status pages with different settings → Each behaves independently
4. ✅ Group monitors → No charts shown (expected behavior)
5. ✅ Database migration → Runs automatically on server restart
6. ✅ Existing status pages → Default to charts hidden (backwards compatible)

### Browser Compatibility
- Tested on modern browsers with ES6+ support
- Charts render using Chart.js with Canvas support

## 🔄 Migration Notes

- **Automatic**: Migration runs automatically when server starts
- **Safe**: No manual intervention required
- **Backwards Compatible**: All existing status pages default to `show_response_time = false`
- **Opt-in**: Administrators must enable the feature per status page

