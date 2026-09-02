'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "616c99fb8e49e8ff4b24e2d6efccb5a5",
"icons/Icon-192.png": "3135281cf80c3410e96f1e4ffd5cf0f6",
"icons/Icon-maskable-512.png": "238f4077ed418840646eb474c45c6b12",
"icons/aya_portrait.png": "4f7d7f10258ef802ac0495c2e619d10c",
"icons/Icon-maskable-192.png": "3135281cf80c3410e96f1e4ffd5cf0f6",
"icons/Icon-512.png": "238f4077ed418840646eb474c45c6b12",
"index.html": "41daa78891c0dce1100bbefeed6a5b00",
"/": "41daa78891c0dce1100bbefeed6a5b00",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"favicon.png": "06236a1d033c8e58b6da6ac38f0a0e16",
"assets/AssetManifest.json": "88573e98919010feccc46536e2791ceb",
"assets/AssetManifest.bin.json": "2206959f0ef2e865dfc3f5f444e80e67",
"assets/NOTICES": "12854ca442a194b1de8dd97a3cc929de",
"assets/fonts/MaterialIcons-Regular.otf": "3ab69e65b1587eb8cafd612f510b36e3",
"assets/FontManifest.json": "127f9b583639df7ea0cbe1cb1b325057",
"assets/AssetManifest.bin": "1d6a80c761d9d9cdd754c82600272e67",
"assets/assets/images/aya_hero_flag_photo.png": "571406fbf07a3563cc5caec19de90b57",
"assets/assets/images/certificates/certificate_graphic_design.png": "185d40d7c842173121d5d953b750ab87",
"assets/assets/images/services_hero_banner.png": "e3ed2c30ab6ecc57d234f616b7d7a5be",
"assets/assets/images/aya_portrait_photo.png": "f1e4f74f4b25d37f405f635853b90c12",
"assets/assets/images/aya_hero_mobile.png": "c3f6575a67a16974e3db0ac7442b8f1c",
"assets/assets/images/vodafone_cash_logo.png": "28c933e638c23b847709c17f0ebd3f33",
"assets/assets/images/instapay_logo.png": "610861f7be9e8c84da97f11a7a52dc1d",
"assets/assets/images/aya_portrait.png": "f55917f38ec663987a7502f086e4da05",
"assets/assets/images/projects/project_2/cover.jpg": "2cde02545ed15650eab8affce3f40813",
"assets/assets/images/projects/project_2/2.jpg": "be64692e4bacf441cf71208fdc7d1189",
"assets/assets/images/projects/project_2/1.jpg": "df2802c077b8325aead5cebb66a2abb4",
"assets/assets/images/projects/project_2/4.jpg": "d8115f2171777136ef2ded89027ef8b2",
"assets/assets/images/projects/project_2/5.jpg": "8cb10b5614b55ad74554900093d97922",
"assets/assets/images/projects/project_2/3.jpg": "39cacd29ff89323e435e73b3dc35ed63",
"assets/assets/images/service_highlight_1.png": "bc9cebcb0c31de81df9b69a18460be86",
"assets/assets/images/private_workshop_promo.png": "1514735b0f859ee5943fad1479f36aa1",
"assets/assets/images/advertising_designs_promo.png": "8b7e3c04e90ac00448a12ce113461124",
"assets/assets/images/service_highlight_0.png": "e07a1ab5b081d39bab365644fc9697fe",
"assets/assets/images/service_highlight_2.png": "7543bdd720ff43f0a8d6527031729fff",
"assets/assets/fonts/Cairo-Light.ttf": "8078edb223451b37ee9e678c3b4b2f73",
"assets/assets/fonts/Poppins-Bold.ttf": "92934d92f57e49fc6f61075c2aeb7689",
"assets/assets/fonts/Cairo-Bold.ttf": "08f051a1822e014b22374926f1406d01",
"assets/assets/fonts/Poppins-SemiBold.ttf": "2c63e05091c7d89f6149c274971c7c23",
"assets/assets/fonts/Cairo-ExtraBold.ttf": "5ce7df38518378257d6df38e39db5a6e",
"assets/assets/fonts/Poppins-ExtraBold.ttf": "12fa32ab93fb44850f24fc1da0d6004d",
"assets/assets/fonts/Cairo-Regular.ttf": "5dacd3d88fa294c5c6263d4041a34935",
"assets/assets/fonts/Cairo-Black.ttf": "5e8d1abc73e3cb2f4e4f28e8f1266810",
"assets/assets/fonts/Poppins-Regular.ttf": "09acac7457bdcf80af5cc3d1116208c5",
"assets/assets/fonts/Cairo-SemiBold.ttf": "a847fd89b0c852cfaa85478f1ef88612",
"assets/assets/fonts/Cairo-ExtraLight.ttf": "4ebc824ed5df082492eceb0969893ab7",
"assets/assets/fonts/Poppins-Medium.ttf": "20aaac2ef92cddeb0f12e67a443b0b9f",
"assets/assets/fonts/Cairo-Medium.ttf": "700c074c00ff17e59cc58449cfb85e75",
"assets/assets/icon/app_icon.png": "22a17caa4bff938e45aff60e915361ab",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"main.dart.js": "623bf5672f576e0e9f1d88d5b168a076",
"googlefd0edbfdde9e9f83.html": "d393302aa072d3e16449ba62e8dc7b60",
"flutter_bootstrap.js": "96b08d0e998bda5d5c0451772d8bde29",
"manifest.json": "d2e7d15a9aea41cdbf334dd74edfe7e7"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
