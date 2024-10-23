NB! The index.html is generated automatically as part of the build process in `./packages/komodo_wallet_build_transformer`. Do not edit it manually.
Changes applied to `template.html` will be reflected in the generated `index.html` file.

If you need to manually rebuild `index.html`, you can run the following command:

```bash
npm install && npm run build
```

If `index.html` is not present after running `flutter build`/`flutter run`, it means that the build steps have not been run. Please run `flutter clean && flutter pub get` and then try again. If issues persist, please ensure you are using the latest Flutter SDK and have set up your environment correctly as per our [project setup docs](/docs/PROJECT_SETUP.md).