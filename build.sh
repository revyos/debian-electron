set -e
source metadata.sh

_dirname=$_pkgname-$_electron_ver
_dirpath=$(realpath $_dirname)
cd $_dirname

export CC=clang CXX=clang++ AR=ar NM=nm

# https://github.com/webpack/webpack/issues/14532
export NODE_OPTIONS=--openssl-legacy-provider

_gn_args=(
  'custom_toolchain="//build/toolchain/linux/unbundle:default"'
  'host_toolchain="//build/toolchain/linux/unbundle:default"'
  'clang_use_chrome_plugins=false'

  # disabled features
  'is_debug=false'
  'use_goma=false'
  'use_sysroot=false'
  'use_allocator="none"'
  'use_libjpeg_turbo=true'
  'use_custom_libcxx=false'
  'use_gnome_keyring=false'
  'optimize_webui=false'
  'use_unofficial_version_number=false'
  'enable_vr=false'
  'enable_nacl=false'
  'enable_swiftshader=false'
  'dawn_use_swiftshader=false'
  'build_dawn_tests=false'
  'enable_reading_list=false'
  'enable_iterator_debugging=false'
  'enable_hangout_services_extension=false'
  'angle_has_histograms=false'
  'build_angle_perftests=false'
  'enable_js_type_check=false'
  'treat_warnings_as_errors=false'
  'use_qt=false'
  'is_cfi=false'
  'use_thin_lto=false'
  'chrome_pgo_phase=0'

  # enabled features
  'use_gio=true'
  'is_official_build=true'
  'symbol_level=0'
  'use_pulseaudio=true'
  'link_pulseaudio=true'
  'rtc_use_pipewire=true'
  'icu_use_data_file=true'
  # 'enable_widevine=true'
  'v8_enable_backtrace=true'
  'use_system_zlib=true'
  'use_system_lcms2=true'
  'use_system_libjpeg=true'
  'use_system_libpng=true'
  'use_system_freetype=true'
  'use_system_libopenjpeg2=true'
  'concurrent_links=1'
  'proprietary_codecs=true'
  'ffmpeg_branding="Chrome"'
  'disable_fieldtrial_testing_config=true'
)

cd src
gn gen out/Release --args="import(\"//electron/build/args/release.gn\") ${_gn_args[*]}"
ninja -C out/Release electron
ninja -C out/Release electron_dist_zip
