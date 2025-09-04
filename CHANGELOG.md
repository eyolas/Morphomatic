# Changelog

# [1.0.2](https://github.com/eyolas/Morphomatic/compare/v1.0.1...v1.0.2) - (2025-09-04)

## <!-- 1 -->🐛 Bug Fixes

- **release:** Add --latest argument to changelog generation step ([63146f7](https://github.com/eyolas/Morphomatic/commit/63146f77a6815429b1a1dc3d82dd05a8c757b4b6))  - (eyolas)
- **toc:** Update interface version to support new features ([43bc8f9](https://github.com/eyolas/Morphomatic/commit/43bc8f9b5e36e11d1435211dedb46b2654d57131))  - (eyolas)
- **readme:** Update screenshot paths to correct images ([592dcb2](https://github.com/eyolas/Morphomatic/commit/592dcb25de24d56fcf7b1b3d391a447dbfb45beb))  - (eyolas)

## <!-- 30 -->📝 Other

- PR [#5](https://github.com/eyolas/Morphomatic/pull/5): update CHANGELOG for v1.0.1 ([3697196](https://github.com/eyolas/Morphomatic/commit/3697196cb2c87292ac96fdda825f921851d4f8fe))  - (David Touzet)

## <!-- 7 -->⚙️ Miscellaneous Tasks

- Update CHANGELOG for v1.0.1 ([2ac7505](https://github.com/eyolas/Morphomatic/commit/2ac75053a6aeecf74bfd668a4062a950008ca851))  - (eyolas)

# [1.0.1](https://github.com/eyolas/Morphomatic/compare/v1.0.0...v1.0.1) - (2025-09-04)

## <!-- 1 -->🐛 Bug Fixes

- **pkgmeta:** Reorganize ignore list for clarity and maintainability ([8845cca](https://github.com/eyolas/Morphomatic/commit/8845ccabe3eacdcacd6a8ab8dd5c6f138a2771f5))  - (eyolas)
- **release:** Remove unnecessary args for full changelog generation ([73a3e6f](https://github.com/eyolas/Morphomatic/commit/73a3e6f66ac5b1378e67e39903aa18125ecf60ab))  - (eyolas)

# [1.0.0](https://github.com/eyolas/Morphomatic/tree/v1.0.0) - (2025-09-04)

## <!-- 0 -->🚀 Features

- **renovate:** Add initial configuration for Renovate bot ([e08dd13](https://github.com/eyolas/Morphomatic/commit/e08dd13cdd3fc037785adfcaf7753798e1cd7d8f))  - (eyolas)
- **release:** Enhance workflow to persist changelog and update GitHub release body ([977eda2](https://github.com/eyolas/Morphomatic/commit/977eda203bea255ad3505e2322d781b2898f6427))  - (eyolas)
- **cliff:** Add git-cliff configuration for changelog generation ([32586c6](https://github.com/eyolas/Morphomatic/commit/32586c6d3a15e51f14558bfe60cb242a1163dc26))  - (eyolas)

## <!-- 1 -->🐛 Bug Fixes

- **pkgmeta:** Update ignore list and improve metadata in Morphomatic.toc ([14322d0](https://github.com/eyolas/Morphomatic/commit/14322d08eb3f90901a10008e69ccbeb01bee09cb))  - (eyolas)
- **pkgmeta:** Remove unnecessary cliff.toml from ignore list ([28274bb](https://github.com/eyolas/Morphomatic/commit/28274bb8e81720473a4ca850a75a94accaada481))  - (eyolas)
- **release:** Remove unnecessary args for changelog generation ([98018d5](https://github.com/eyolas/Morphomatic/commit/98018d5dbec636722027c0507e87f45042e39f19))  - (eyolas)
- **release:** Simplify changelog generation arguments ([9680708](https://github.com/eyolas/Morphomatic/commit/9680708b40481e7624ee50f32bbd2c746082b01c))  - (eyolas)
- **renovate:** Update commit message configuration for GitHub Actions ([06ebc54](https://github.com/eyolas/Morphomatic/commit/06ebc54a2b6eef75f2455b595f0279e27f8b522c))  - (eyolas)
- **toc:** Update version placeholder to use project version variable ([28d7ca3](https://github.com/eyolas/Morphomatic/commit/28d7ca367e3452b333f81f03f9773d4c827c722d))  - (eyolas)
- Fix debug print function name: correct MM.dMM.dprint to MM.dprint for proper logging functionality. ([29134ec](https://github.com/eyolas/Morphomatic/commit/29134ecdb952449d297508601102714522453874))  - (eyolas)
- Fix bulk selection logic to correctly include or exclude toys in the current view ([7973911](https://github.com/eyolas/Morphomatic/commit/7973911c3e398139a279d4a206a377682805f306))  - (eyolas)

## <!-- 16 -->➕ Add

- Add LICENSE file, update README with new features, and include logo and screenshot assets ([902fbf8](https://github.com/eyolas/Morphomatic/commit/902fbf80ff968bae424d61560dac598ee1777876))  - (eyolas)
- Add release workflow and package metadata for Morphomatic ([f61bf6c](https://github.com/eyolas/Morphomatic/commit/f61bf6cd37fdf1b45ecda3b5a05b8051c6fa278e))  - (eyolas)
- Add linting workflow and update luacheck configuration for Morphomatic ([12b69ae](https://github.com/eyolas/Morphomatic/commit/12b69aebe7209943ae057fde57d1c2de812477f3))  - (eyolas)
- Add libs ([196b73a](https://github.com/eyolas/Morphomatic/commit/196b73a46ad5fe466f4550a276a2121f5312b1a3))  - (David Touzet)
- Add minimap support: integrate minimap button and toggle in settings, update localization for minimap features ([87f6058](https://github.com/eyolas/Morphomatic/commit/87f6058a9838b4648873960657faa4c167e9007a))  - (eyolas)
- Add localization support: implement MM.T function and localize UI strings for better user experience. ([3779368](https://github.com/eyolas/Morphomatic/commit/37793684162fd850ed0f28b697fac11b5cc9e63d))  - (eyolas)
- Add debug slash command to dump MorphomaticDB contents ([4fdbcb7](https://github.com/eyolas/Morphomatic/commit/4fdbcb777ec155526dab2d0047fba6ccfaf7d852))  - (eyolas)
- Add macro creation logic to macro.lua and update settings for auto-creation ([741b89a](https://github.com/eyolas/Morphomatic/commit/741b89a9dc5ce4f091b59e26121c21eb65780598))  - (eyolas)
- Add debug output to /mmprobe and enhance PreClick logging for secure button ([209d52a](https://github.com/eyolas/Morphomatic/commit/209d52a7659dcb61c5eecb101bf284c90bcdb0d5))  - (eyolas)
- Add function to safely resolve localized toy names from ToyBox API and improve PrepareSecureUse logic ([37db238](https://github.com/eyolas/Morphomatic/commit/37db238cc1f729308375f346eb29237bc28d5612))  - (eyolas)
- Add debug output for item and spell information in DebugDump function ([91dfc16](https://github.com/eyolas/Morphomatic/commit/91dfc16514147b10cedfe156f1b81155e84a4595))  - (eyolas)
- Add reset selection button to clear explicit exclusions in settings UI ([a84c72e](https://github.com/eyolas/Morphomatic/commit/a84c72ed90b114fc10b5fc6afccd6bec4a003a47))  - (eyolas)
- Add debug command for analyzing toy pool and enhance slash command functionality ([e32d9bd](https://github.com/eyolas/Morphomatic/commit/e32d9bdbd24f214c30a8b82fa3ace4c72fe86deb))  - (eyolas)

## <!-- 2 -->🚜 Refactor

- Refactor .luacheckrc for improved global definitions and readability; remove unused parseBool function from bootstrap.lua; clean up macro.lua by removing TotalMacroCount function ([f219d74](https://github.com/eyolas/Morphomatic/commit/f219d7481f236ad5633be85765e097b26679595b))  - (eyolas)
- Refactor .luacheckrc to use plain Lua 5.1 rules and reorganize global definitions for clarity ([2783ed8](https://github.com/eyolas/Morphomatic/commit/2783ed84df017dc8f63fa13b0ad34c84dd5e84ec))  - (eyolas)
- Refactor lint workflow to streamline Lua and LuaRocks setup, removing unnecessary installation steps ([905847b](https://github.com/eyolas/Morphomatic/commit/905847bb9409e970458587d89ecc090e9e7c3264))  - (eyolas)
- Refactor and update library dependencies

- Added LibDBIcon-1.0 as a new library for minimap icon integration.
- Removed the old LibDataBroker-1.1 implementation and replaced it with a new version.
- Reintroduced LibStub with updated structure and functionality.
- Updated Morphomatic.toc to include CallbackHandler-1.0 and embedded libraries.
- Refactored minimap.lua to utilize the new library structure for minimap button registration.
- Adjusted settings.lua to always show the minimap toggle option, as libraries are now embedded. ([8313c87](https://github.com/eyolas/Morphomatic/commit/8313c87cab4c780b5f6ac767a3e6972020e41273))  - (eyolas)
- Refactor macro handling: improve macro body construction and update documentation for clarity ([886daf0](https://github.com/eyolas/Morphomatic/commit/886daf0ede4b27605ee261ff1855f91e4957265c))  - (eyolas)
- Refactor macro documentation: clarify macro creation logic and improve comments in macro.lua ([5d82f3a](https://github.com/eyolas/Morphomatic/commit/5d82f3a895e5305b804c2d4f79a3c6a78a0338d0))  - (eyolas)
- Refactor macro handling: improve documentation and streamline macro creation logic in Morphomatic. ([1615315](https://github.com/eyolas/Morphomatic/commit/1615315b35ea2ae4b10e756fe8b34b65d9bc7423))  - (eyolas)
- Refactor macro handling: update macro creation logic and improve debug output for Morphomatic macro index. ([00f43d9](https://github.com/eyolas/Morphomatic/commit/00f43d9f839181860a704dfe53c6baca5c5a823e))  - (eyolas)
- Refactor debug logging: replace print statements with MM.dprint for consistent debug output across the addon. ([e17528a](https://github.com/eyolas/Morphomatic/commit/e17528aee2dd9112c3d92dddbb163b9d51d28ea6))  - (eyolas)
- Refactor event handling and slash command logic: simplify command structure, remove unused commands, and enhance readability. ([8046fd8](https://github.com/eyolas/Morphomatic/commit/8046fd8a09a560672469e902adc98b9a16c73ed8))  - (eyolas)
- Refactor toy selection messages and UI elements: update print statements and button labels to emphasize favorites. Adjust button sizes for better usability. ([fa87831](https://github.com/eyolas/Morphomatic/commit/fa87831794e10683aa65d00dc13ffca74fe53f4d))  - (eyolas)
- Refactor floating button logic: improve visual feedback for locked/unlocked states and enhance tooltip messages. Update settings to refresh button visuals on lock state change. ([1d26abd](https://github.com/eyolas/Morphomatic/commit/1d26abd285a83348d7fd3d6bff623e3f346fd8be))  - (eyolas)
- Refactor EnsureSecureButton to prepare attributes right before the protected click and improve feedback for no eligible toys. ([e091cc2](https://github.com/eyolas/Morphomatic/commit/e091cc2830836b10d8ebebe45f7fb632085bfef8))  - (eyolas)
- Refactor code for improved readability and consistency across multiple files ([402409f](https://github.com/eyolas/Morphomatic/commit/402409f3fa78f269b5f8b18eea3cf2f56f04927f))  - (eyolas)
- Refactor floating button creation and improve secure use preparation logic for better readability and reliability ([f0586e8](https://github.com/eyolas/Morphomatic/commit/f0586e80780b2287dca5fe2788258b629467072b))  - (eyolas)
- Refactor PrepareSecureUse function for improved readability and streamlined macro generation ([1d29a11](https://github.com/eyolas/Morphomatic/commit/1d29a11f189558f8766c5cacf12fe465b2837e0e))  - (eyolas)
- Refactor settings.lua for improved readability and structure; enhance macro creation logic and checklist rendering ([cc0263b](https://github.com/eyolas/Morphomatic/commit/cc0263bf026c6a19ed6cc0ae883ba27be0ab81c6))  - (eyolas)

## <!-- 26 -->🔄 Update

- Update lint workflow to use Lua 5.4 and latest LuaRocks action versions ([37017d7](https://github.com/eyolas/Morphomatic/commit/37017d792d4159acdc5660fea9c171bb8808d8d3))  - (eyolas)
- Update macro section positioning in settings panel to align with minimap toggle ([fc5ae87](https://github.com/eyolas/Morphomatic/commit/fc5ae870b7b78d260d2c3620913eb7fe63297439))  - (eyolas)
- Update floating button icon to use Orb of Deception or fallback icon, and ensure macro uses the correct icon retrieval method. ([c489423](https://github.com/eyolas/Morphomatic/commit/c4894232ceb1ab35059a9b2420a333f238d36536))  - (eyolas)
- Update README.md to enhance usage instructions and clarify file structure ([a2b3ebe](https://github.com/eyolas/Morphomatic/commit/a2b3ebe853e6447bc84f6dffea248ec4ed6305c4))  - (eyolas)
- Update toys database with additional cosmetic items for enhanced gameplay experience ([f664cc7](https://github.com/eyolas/Morphomatic/commit/f664cc743e4fb99357246e3c4e3666171e89663b))  - (eyolas)

## <!-- 29 -->👷 CI/CD

- PR [#3](https://github.com/eyolas/Morphomatic/pull/3): Pin dependencies ([e4c64cf](https://github.com/eyolas/Morphomatic/commit/e4c64cff3bc624f6f08c98cad357f404c9a1f0fa))  - (David Touzet)
- Enhance floating button functionality: register clicks explicitly, prepare button for random toy on PreClick, and improve debug output for secure actions. ([805026d](https://github.com/eyolas/Morphomatic/commit/805026d7641fed29c550e289f40f9ead7de23e59))  - (eyolas)

## <!-- 30 -->📝 Other

- PR [#4](https://github.com/eyolas/Morphomatic/pull/4): Update GitHub Actions (major) ([ee8d920](https://github.com/eyolas/Morphomatic/commit/ee8d9209f06e4a50ce3ac00f57b085182b48b426))  - (David Touzet)
- Adjust minimap toggle position in settings panel for better alignment ([9b332db](https://github.com/eyolas/Morphomatic/commit/9b332dbecc0d28eaff3b8822f919706e5c948f13))  - (eyolas)
- Adjust minimap toggle position in settings panel for better alignment ([c027435](https://github.com/eyolas/Morphomatic/commit/c0274359109d38a31aa4a376afd0f5c34b17e637))  - (eyolas)
- Stylua ([91bfc4e](https://github.com/eyolas/Morphomatic/commit/91bfc4eec9a6a67bdb4d99e5d40543138af25aea))  - (eyolas)
- Stylua ([92c52ef](https://github.com/eyolas/Morphomatic/commit/92c52ef9a9799ce72ef5df8281e54fcd7e9e3499))  - (eyolas)
- Enhance slash command options: allow both "options" and "opt" to open settings. ([98fb398](https://github.com/eyolas/Morphomatic/commit/98fb39894f291724351e95ad7ef35d785b646de6))  - (eyolas)
- Stylua ([c0858fc](https://github.com/eyolas/Morphomatic/commit/c0858fcac690d4c2bc9a70af1407882306ab212b))  - (eyolas)
- Enhance slash command functionality: add new commands for button visibility, toy selection, and cooldown management. Improve event handling and macro creation logic. ([22dcd62](https://github.com/eyolas/Morphomatic/commit/22dcd62a97fa2b484c0e8bb7be50c4ed03844727))  - (eyolas)
- Enhance toys management: update settings for runtime cooldown options, improve list filtering, and refine bulk selection functionality. ([1a1a07f](https://github.com/eyolas/Morphomatic/commit/1a1a07fd362673453612a67c0cbffe7a00780cea))  - (eyolas)
- Enhance toys management: add bulk selection actions, improve checklist rendering, and update UI layout for better usability. ([44f994f](https://github.com/eyolas/Morphomatic/commit/44f994f474ac23a20f7d1945ce43324e9dde6006))  - (eyolas)
- Enhance macro creation and secure button functionality: improve macro body syntax, ensure secure button existence, and add reliable toy name resolution. ([38a5396](https://github.com/eyolas/Morphomatic/commit/38a539608cd9fc38ba4daba1be0db83b101169bb))  - (eyolas)
- Enhance macro and button functionality: add retry after combat, improve secure button preparation, and streamline macro creation process ([0bc359a](https://github.com/eyolas/Morphomatic/commit/0bc359a1c15bb65c6073ba2b671a5c603ff7326a))  - (eyolas)
- Enhance PrepareSecureUse function to improve toy selection logic and error handling ([eb572e1](https://github.com/eyolas/Morphomatic/commit/eb572e14c4162ace78c3922664ac38a32655d23d))  - (eyolas)
- First commit ([e1504e7](https://github.com/eyolas/Morphomatic/commit/e1504e7cdeb482c2aafb2e0fb7e8dc45a6caca55))  - (eyolas)

## <!-- 7 -->⚙️ Miscellaneous Tasks

- **deps:** Update GitHub Actions ([94b296f](https://github.com/eyolas/Morphomatic/commit/94b296f9e3135154d600e63cd86cd1807bc4aa67))  - (renovate[bot])
- **deps:** Pin dependencies ([c46e1b9](https://github.com/eyolas/Morphomatic/commit/c46e1b9abbdb8536bdfa00ecc84ad0d6d26529f9))  - (renovate[bot])
- **cliff:** Remove git-cliff configuration file ([a473dbb](https://github.com/eyolas/Morphomatic/commit/a473dbbcfb07af01f91a1664913b05f80dd5906f))  - (eyolas)
- **pkgmeta:** Update ignore list to exclude unnecessary files ([719d7d3](https://github.com/eyolas/Morphomatic/commit/719d7d381f1eef0a60df737755e6f984de19e981))  - (eyolas)

<!-- generated by git-cliff -->
