'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "d2b9f2e75865ec4fde955a284b446aec",
"assets/AssetManifest.bin.json": "101432af8512eb00841aef8ee3ae8176",
"assets/AssetManifest.json": "fb200faa03cf246c7d51cf45f071f860",
"assets/assets/fonts/Cairo-Black.ttf": "5e8d1abc73e3cb2f4e4f28e8f1266810",
"assets/assets/fonts/Cairo-Bold.ttf": "08f051a1822e014b22374926f1406d01",
"assets/assets/fonts/Cairo-ExtraBold.ttf": "5ce7df38518378257d6df38e39db5a6e",
"assets/assets/fonts/Cairo-ExtraLight.ttf": "4ebc824ed5df082492eceb0969893ab7",
"assets/assets/fonts/Cairo-Light.ttf": "8078edb223451b37ee9e678c3b4b2f73",
"assets/assets/fonts/Cairo-Medium.ttf": "700c074c00ff17e59cc58449cfb85e75",
"assets/assets/fonts/Cairo-Regular.ttf": "5dacd3d88fa294c5c6263d4041a34935",
"assets/assets/fonts/Cairo-SemiBold.ttf": "a847fd89b0c852cfaa85478f1ef88612",
"assets/assets/fonts/Poppins-Bold.ttf": "92934d92f57e49fc6f61075c2aeb7689",
"assets/assets/fonts/Poppins-ExtraBold.ttf": "12fa32ab93fb44850f24fc1da0d6004d",
"assets/assets/fonts/Poppins-Medium.ttf": "20aaac2ef92cddeb0f12e67a443b0b9f",
"assets/assets/fonts/Poppins-Regular.ttf": "09acac7457bdcf80af5cc3d1116208c5",
"assets/assets/fonts/Poppins-SemiBold.ttf": "2c63e05091c7d89f6149c274971c7c23",
"assets/assets/icon/app_icon.png": "22a17caa4bff938e45aff60e915361ab",
"assets/assets/images/advertising_designs_promo.png": "8b7e3c04e90ac00448a12ce113461124",
"assets/assets/images/aya_hero_flag_photo.png": "21927975b9a924b3b66e5aec709322a9",
"assets/assets/images/aya_hero_mobile.png": "c3f6575a67a16974e3db0ac7442b8f1c",
"assets/assets/images/aya_portrait.png": "f55917f38ec663987a7502f086e4da05",
"assets/assets/images/aya_portrait_photo.png": "f1e4f74f4b25d37f405f635853b90c12",
"assets/assets/images/certificates/certificate_ai_seminar_2024.jpg": "c78964e70ac0ef9b0b6c7575bad08a72",
"assets/assets/images/certificates/certificate_art_design_seminar_2025.jpg": "f5d32520be1043dd078a8ca355ee23be",
"assets/assets/images/certificates/certificate_graduation_2023.jpg": "1b8959575852a06a4efa12684e6dab74",
"assets/assets/images/certificates/certificate_graphic_design.png": "185d40d7c842173121d5d953b750ab87",
"assets/assets/images/clients/client_1.png": "e4a3c0b6cb9c33d05fcd456df84354b7",
"assets/assets/images/clients/client_2.png": "d69f4dd4ebde0ca366558c650e827954",
"assets/assets/images/clients/client_3.png": "a591d72c9e9fabc31147bb7daeff974a",
"assets/assets/images/clients/client_4.png": "1c200b4df6292311f159cc3e3129a9cd",
"assets/assets/images/clients/client_5.png": "c40d944e0a08ccfa08090fc993585999",
"assets/assets/images/clients/client_6.png": "6baaae9c8c7a319f0ff1896f3cec59b1",
"assets/assets/images/illustration_khat.jpg": "8914934a3a5181f14ef94e306f841954",
"assets/assets/images/illustration_rasm.jpg": "dac522aa40e8ec1bde5a93a965daefda",
"assets/assets/images/instapay_logo.png": "610861f7be9e8c84da97f11a7a52dc1d",
"assets/assets/images/private_workshop_promo.png": "1514735b0f859ee5943fad1479f36aa1",
"assets/assets/images/projects/project_2/1.jpg": "df2802c077b8325aead5cebb66a2abb4",
"assets/assets/images/projects/project_2/2.jpg": "be64692e4bacf441cf71208fdc7d1189",
"assets/assets/images/projects/project_2/3.jpg": "39cacd29ff89323e435e73b3dc35ed63",
"assets/assets/images/projects/project_2/4.jpg": "d8115f2171777136ef2ded89027ef8b2",
"assets/assets/images/projects/project_2/5.jpg": "8cb10b5614b55ad74554900093d97922",
"assets/assets/images/projects/project_2/cover.jpg": "2cde02545ed15650eab8affce3f40813",
"assets/assets/images/services_hero_banner.png": "e3ed2c30ab6ecc57d234f616b7d7a5be",
"assets/assets/images/service_designing.jpg": "1f9a6df70ffc14647ee441f8524cf05c",
"assets/assets/images/service_highlight_0.png": "e07a1ab5b081d39bab365644fc9697fe",
"assets/assets/images/service_highlight_1.png": "bc9cebcb0c31de81df9b69a18460be86",
"assets/assets/images/service_highlight_2.png": "7543bdd720ff43f0a8d6527031729fff",
"assets/assets/images/service_mentoring.jpg": "d6cb9b82d9947c0dccb91e8c05e0ebab",
"assets/assets/images/service_workshop.jpg": "76c1473236108fcd52a15be09cc7bb20",
"assets/assets/images/sold_out_stamp.png": "457b231d2a6acaaf94bf760afc2ee84b",
"assets/assets/images/vodafone_cash_logo.png": "28c933e638c23b847709c17f0ebd3f33",
"assets/FontManifest.json": "6e2ede08330018b167fdf8d54e149abf",
"assets/fonts/MaterialIcons-Regular.otf": "07c656382ee5f9ccd8c3394ce3fcb2dd",
"assets/NOTICES": "1acde49b6c22f964e31aaa25207e3c04",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "33bc93feeef5112a6679e1f322073309",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "46be639d952abe98effde36da35e7701",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "48b92e8451309fdcb73d294f0f6e9830",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"CNAME": "66ba4b2a89ad905e4c19c9bd4aee6573",
"favicon.png": "06236a1d033c8e58b6da6ac38f0a0e16",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "d840ef3e43d84eb1f6ee8ba254faf343",
"googlefd0edbfdde9e9f83.html": "d393302aa072d3e16449ba62e8dc7b60",
"icons/aya_portrait.png": "4f7d7f10258ef802ac0495c2e619d10c",
"icons/Icon-192.png": "3135281cf80c3410e96f1e4ffd5cf0f6",
"icons/Icon-512.png": "238f4077ed418840646eb474c45c6b12",
"icons/Icon-maskable-192.png": "3135281cf80c3410e96f1e4ffd5cf0f6",
"icons/Icon-maskable-512.png": "238f4077ed418840646eb474c45c6b12",
"index.html": "cfbbbb5060d1ce36f2a49f755258cb79",
"/": "cfbbbb5060d1ce36f2a49f755258cb79",
"main.dart.js": "c5c8392c812c93b50627a0b194f7ea3d",
"manifest.json": "65b247f86aa17e8093e0871a4d6284dc",
"version.json": "616c99fb8e49e8ff4b24e2d6efccb5a5"};
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
