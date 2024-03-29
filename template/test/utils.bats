#!/usr/bin/env bats

# shellcheck disable=SC2030,SC2031,SC2034,SC2230,SC2190

load ../node_modules/bats-support/load.bash
load ../node_modules/bats-assert/load.bash
load ../lib/utils
load ./lib/test_utils

setup_file() {
	PROJECT_DIR="$(realpath "$(dirname "$BATS_TEST_DIRNAME")")"
	export PROJECT_DIR
	cd "$PROJECT_DIR"
	clear_lock git
}

teardown_file() {
	clear_lock git
}

setup() {
	setup_test
}

teardown() {
	teardown_test
}

# TODO: check tests below you really adopt

@test "asdf_<YOUR TOOL ELC>_log__install" {
	asdf_<YOUR TOOL ELC>_init "install"
	assert [ "$(asdf_<YOUR TOOL ELC>_log)" = "${ASDF_DATA_DIR}/tmp/asdf-<YOUR TOOL LC>/1.6.0/install.log" ]
}

@test "asdf_<YOUR TOOL ELC>_log__download" {
	asdf_<YOUR TOOL ELC>_init "download"
	assert [ "$(asdf_<YOUR TOOL ELC>_log)" = "${ASDF_DATA_DIR}/tmp/asdf-<YOUR TOOL LC>/1.6.0/download.log" ]
}

@test "asdf_<YOUR TOOL ELC>_init__defaults" {
	unset ASDF_<YOUR TOOL EUC>_SILENT
	asdf_<YOUR TOOL ELC>_init "download"

	# Configurable
	assert_equal "$ASDF_<YOUR TOOL EUC>_ACTION" "download"
	assert_equal "$ASDF_<YOUR TOOL EUC>_REMOVE_TEMP" "yes"
	assert_equal "$ASDF_<YOUR TOOL EUC>_DEBUG" "no"
	assert_equal "$ASDF_<YOUR TOOL EUC>_SILENT" "no"

	# Non-configurable
	assert_equal "$ASDF_<YOUR TOOL EUC>_TEMP" "${ASDF_DATA_DIR}/tmp/asdf-<YOUR TOOL LC>/1.6.0"
	assert_equal "$ASDF_<YOUR TOOL EUC>_DOWNLOAD_PATH" "${ASDF_<YOUR TOOL EUC>_TEMP}/download"
	assert_equal "$ASDF_<YOUR TOOL EUC>_INSTALL_PATH" "${ASDF_<YOUR TOOL EUC>_TEMP}/install"
}

@test "asdf_<YOUR TOOL ELC>_init__configuration" {
	ASDF_<YOUR TOOL EUC>_REMOVE_TEMP="no"
	ASDF_<YOUR TOOL EUC>_DEBUG="yes"
	ASDF_<YOUR TOOL EUC>_SILENT="yes"
	ASDF_<YOUR TOOL EUC>_TEMP="${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/configured"

	asdf_<YOUR TOOL ELC>_init "install"

	# Configurable
	assert_equal "$ASDF_<YOUR TOOL EUC>_ACTION" "install"
	assert_equal "$ASDF_<YOUR TOOL EUC>_REMOVE_TEMP" "no"
	assert_equal "$ASDF_<YOUR TOOL EUC>_DEBUG" "yes"
	assert_equal "$ASDF_<YOUR TOOL EUC>_SILENT" "yes"

	# Non-configurable
	assert_equal "$ASDF_<YOUR TOOL EUC>_TEMP" "${ASDF_DATA_DIR}/tmp/asdf-<YOUR TOOL LC>/1.6.0"
	assert_equal "$ASDF_<YOUR TOOL EUC>_DOWNLOAD_PATH" "${ASDF_<YOUR TOOL EUC>_TEMP}/download"
	assert_equal "$ASDF_<YOUR TOOL EUC>_INSTALL_PATH" "${ASDF_<YOUR TOOL EUC>_TEMP}/install"
}

@test "asdf_<YOUR TOOL ELC>_cleanup" {
	original="$ASDF_<YOUR TOOL EUC>_TEMP"
	run asdf_<YOUR TOOL ELC>_init &&
		asdf_<YOUR TOOL ELC>_cleanup &&
		[ -z "$ASDF_<YOUR TOOL EUC>_TEMP" ] &&
		[ ! -d "$original" ] &&
		[ "$ASDF_<YOUR TOOL EUC>_INITIALIZED" = "no" ]
	assert_success
	# TODO ASDF_<YOUR TOOL EUC>_STDOUT/ASDF_<YOUR TOOL EUC>_STDERR redirection test
}

@test "asdf_<YOUR TOOL ELC>_sort_versions" {
	expected="0.2.2 1.1.1 1.2.0 1.6.0"
	output="$(printf "1.6.0\n0.2.2\n1.1.1\n1.2.0" | asdf_<YOUR TOOL ELC>_sort_versions | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_list_all_versions__contains_tagged_releases" {
	run asdf_<YOUR TOOL ELC>_list_all_versions

	# Can't hardcode the ever-growing list of releases, so just check for a few known ones
	assert_line 0.10.2
	assert_line 1.4.0
	assert_line 1.6.0
}

@test "asdf_<YOUR TOOL ELC>_list_all_versions__displays_in_order" {
	assert [ "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.0' | sed 's/:.*//')" -gt "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.4.8' | sed 's/:.*//')" ]
	assert [ "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.2' | sed 's/:.*//')" -gt "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.0' | sed 's/:.*//')" ]
	assert [ "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.4' | sed 's/:.*//')" -gt "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.2' | sed 's/:.*//')" ]
	assert [ "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.6' | sed 's/:.*//')" -gt "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.4' | sed 's/:.*//')" ]
	assert [ "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.8' | sed 's/:.*//')" -gt "$(asdf_<YOUR TOOL ELC>_list_all_versions | grep -Fn '1.6.6' | sed 's/:.*//')" ]
}

@test "asdf_<YOUR TOOL ELC>_normalize_os" {
	mkdir -p "${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/bin"
	declare -A uname_outputs=(
		["Darwin"]="macos"
		["Linux"]="linux"
		["MINGW"]="windows" # not actually supported by asdf?
		["Unknown"]="unknown"
	)
	for uname_output in "${!uname_outputs[@]}"; do
		# mock uname
		ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="${uname_output}"
		expected_os="${uname_outputs[$uname_output]}"
		output="$(asdf_<YOUR TOOL ELC>_normalize_os)"
		assert_equal "$output" "$expected_os"
	done
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__basic" {
	declare -A machine_names=(
		["i386"]="i686"
		["i486"]="i686"
		["i586"]="i686"
		["i686"]="i686"
		["x86"]="i686"
		["x32"]="i686"

		["ppc64le"]="powerpc64le"
		["unknown"]="unknown"
	)

	for machine_name in "${!machine_name[@]}"; do
		# mock uname
		ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="$machine_name"
		expected_arch="${machine_names[$machine_name]}"
		output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
		assert_equal "$output" "$expected_arch"
	done
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__i686__x86_64_docker" {
	# In x86_64 docker hosts running x86 containers,
	# the kernel uname will show x86_64 so we have to properly detect using the
	# __amd64 gcc define.

	# Expect i686 when __amd64 is not defined
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	expected_arch="i686"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="amd64"
	expected_arch="i686"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x64"
	expected_arch="i686"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	# Expect x86_64 only when __amd64 is defined
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"

	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	expected_arch="x86_64"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="amd64"
	expected_arch="x86_64"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x64"
	expected_arch="x86_64"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__arm32__via_gcc" {
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm"
	for arm_version in {5..7}; do
		ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __ARM_ARCH ${arm_version}"
		expected_arch="armv${arm_version}"
		output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
		assert_equal "$output" "$expected_arch"
	done
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__armel__via_dpkg" {
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm"
	ASDF_<YOUR TOOL EUC>_MOCK_DPKG_ARCHITECTURE="armel"
	expected_arch="armv5"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__armhf__via_dpkg" {
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm"
	ASDF_<YOUR TOOL EUC>_MOCK_DPKG_ARCHITECTURE="armhf"
	expected_arch="armv7"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__arm__no_dpkg_no_gcc" {
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm"
	expected_arch="armv5"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__armv7l__no_dpkg_no_gcc" {
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="armv7l"
	expected_arch="armv7"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"
}

@test "asdf_<YOUR TOOL ELC>_normalize_arch__arm64" {
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm64"
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Darwin"
	expected_arch="arm64"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	expected_arch="aarch64"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"

	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="aarch64"
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	expected_arch="aarch64"
	output="$(asdf_<YOUR TOOL ELC>_normalize_arch)"
	assert_equal "$output" "$expected_arch"
}

@test "asdf_<YOUR TOOL ELC>_pkg_mgr" {
	mkdir -p "${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/bin"
	declare -a bin_names=(
		"brew"
		"apt-get"
		"apk"
		"pacman"
		"dnf"
	)
	for bin_name in "${bin_names[@]}"; do
		# mock package manager
		touch "${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/bin/${bin_name}"
		chmod +x "${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/bin/${bin_name}"
		output="$(PATH="${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/bin" asdf_<YOUR TOOL ELC>_pkg_mgr)"
		rm "${ASDF_<YOUR TOOL EUC>_TEST_TEMP}/bin/${bin_name}"
		assert_equal "$output" "$bin_name"
	done
}

@test "asdf_<YOUR TOOL ELC>_list_deps__apt_get" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="apt-get"
	expected="xz-utils build-essential"
	output="$(asdf_<YOUR TOOL ELC>_list_deps | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_list_deps__apk" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="apk"
	expected="xz build-base"
	output="$(asdf_<YOUR TOOL ELC>_list_deps | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_list_deps__brew" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="brew"
	expected="xz"
	output="$(asdf_<YOUR TOOL ELC>_list_deps | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_list_deps__pacman" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="pacman"
	expected="xz gcc"
	output="$(asdf_<YOUR TOOL ELC>_list_deps | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_list_deps__dnf" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="dnf"
	expected="xz gcc"
	output="$(asdf_<YOUR TOOL ELC>_list_deps | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_install_deps_cmds__apt_get" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="apt-get"
	expected="apt-get update -q -y && apt-get -qq install -y xz-utils build-essential"
	output="$(asdf_<YOUR TOOL ELC>_install_deps_cmds)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_install_deps_cmds__apk" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="apk"
	expected="apk add --update xz build-base"
	output="$(asdf_<YOUR TOOL ELC>_install_deps_cmds)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_install_deps_cmds__brew" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="brew"
	expected="brew install xz"
	output="$(asdf_<YOUR TOOL ELC>_install_deps_cmds)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_install_deps_cmds__pacman" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="pacman"
	expected="pacman -Syu --noconfirm xz gcc"
	output="$(asdf_<YOUR TOOL ELC>_install_deps_cmds)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_install_deps_cmds__dnf" {
	ASDF_<YOUR TOOL EUC>_MOCK_PKG_MGR="dnf"
	expected="dnf install -y xz gcc"
	output="$(asdf_<YOUR TOOL ELC>_install_deps_cmds)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__linux__x86_64__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="no"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0-linux_x64.tar.xz https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__linux__i686__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="no"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="i686"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0-linux_x32.tar.xz https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__linux__other_archs__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="no"
	declare -a machine_names=(
		"aarch64"
		"armv5"
		"armv6"
		"armv7"
		"powerpc64le"
	)
	for machine_name in "${machine_names[@]}"; do
		ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="$machine_name"
		asdf_<YOUR TOOL ELC>_init "install"
		expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
		output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
		assert_equal "$output" "$expected"
	done
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__linux__x86_64__musl" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="yes"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__linux__other_archs__musl" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="yes"
	declare -a machine_names=(
		"aarch64"
		"armv5"
		"armv6"
		"armv7"
		"i686"
		"powerpc64le"
	)
	for machine_name in "${machine_names[@]}"; do
		ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="$machine_name"
		asdf_<YOUR TOOL ELC>_init "install"
		expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
		output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
		assert_equal "$output" "$expected"
	done
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__macos__x86_64" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Darwin"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__macos__arm64" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Darwin"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm64"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__stable__netbsd__x86_64" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="NetBSD"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://asdf-<YOUR TOOL LC>-lang.org/download/asdf-<YOUR TOOL LC>-1.6.0.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__x86_64__musl" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="yes"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected=""
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__other_archs__musl" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="yes"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	declare -a machine_names=(
		"aarch64"
		"armv5"
		"armv6"
		"armv7"
		"i686"
		"powerpc64le"
	)
	for machine_name in "${machine_names[@]}"; do
		ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="$machine_name"
		asdf_<YOUR TOOL ELC>_init "install"
		expected=""
		output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
		assert_equal "$output" "$expected"
	done
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__x86_64__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="no"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://github.com/asdf-<YOUR TOOL LC>-lang/nightlies/releases/download/latest-version-1-6/linux_x64.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__i686__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="no"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="i686"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://github.com/asdf-<YOUR TOOL LC>-lang/nightlies/releases/download/latest-version-1-6/linux_x32.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__other_archs__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_IS_MUSL="no"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	declare -a machine_names=(
		"armv5"
		"armv6"
		"powerpc64le"
	)
	for machine_name in "${machine_names[@]}"; do
		ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="$machine_name"
		asdf_<YOUR TOOL ELC>_init "install"
		expected=""
		output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
		assert_equal "$output" "$expected"
	done
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__armv7__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="armv7"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://github.com/asdf-<YOUR TOOL LC>-lang/nightlies/releases/download/latest-version-1-6/linux_armv7l.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__linux__aarch64__glibc" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Linux"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="aarch64"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="devel"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://github.com/asdf-<YOUR TOOL LC>-lang/nightlies/releases/download/latest-devel/linux_arm64.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__macos__x86_64" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Darwin"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected="https://github.com/asdf-<YOUR TOOL LC>-lang/nightlies/releases/download/latest-version-1-6/macosx_x64.tar.xz"
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__macos__arm64" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="Darwin"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="arm64"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected=""
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_download_urls__nightly__netbsd__x86_64" {
	ASDF_<YOUR TOOL EUC>_MOCK_OS_NAME="NetBSD"
	ASDF_<YOUR TOOL EUC>_MOCK_MACHINE_NAME="x86_64"
	ASDF_<YOUR TOOL EUC>_MOCK_GCC_DEFINES="#define __amd64 1"
	ASDF_INSTALL_TYPE="ref"
	ASDF_INSTALL_VERSION="version-1-6"
	asdf_<YOUR TOOL ELC>_init "install"
	expected=""
	output="$(asdf_<YOUR TOOL ELC>_download_urls | xargs)"
	assert_equal "$output" "$expected"
}

@test "asdf_<YOUR TOOL ELC>_needs_download__missing_ASDF_DOWNLOAD_PATH" {
	asdf_<YOUR TOOL ELC>_init "install"
	run asdf_<YOUR TOOL ELC>_needs_download
	assert_output "yes"
}

@test "asdf_<YOUR TOOL ELC>_needs_download__with_ASDF_DOWNLOAD_PATH" {
	asdf_<YOUR TOOL ELC>_init "install"
	mkdir -p "$ASDF_DOWNLOAD_PATH"
	run asdf_<YOUR TOOL ELC>_needs_download
	assert_output "no"
}

@test "asdf_<YOUR TOOL ELC>_download__ref" {
	export ASDF_INSTALL_TYPE
	ASDF_INSTALL_TYPE="ref"
	export ASDF_INSTALL_VERSION
	ASDF_INSTALL_VERSION="HEAD"
	asdf_<YOUR TOOL ELC>_init "download"
	get_lock git
	run asdf_<YOUR TOOL ELC>_download
	clear_lock git
	assert_success
	assert [ -d "${ASDF_DOWNLOAD_PATH}/.git" ]
	assert [ -f "${ASDF_DOWNLOAD_PATH}/koch.asdf-<YOUR TOOL LC>" ]
}

@test "asdf_<YOUR TOOL ELC>_download__version" {
	ASDF_DOWNLOAD_PATH="${ASDF_DATA_DIR}/downloads/asdf-<YOUR TOOL LC>/${ASDF_INSTALL_VERSION}"
	asdf_<YOUR TOOL ELC>_init "download"
	get_lock git
	run asdf_<YOUR TOOL ELC>_download
	clear_lock git
	assert_success
	refute [ -d "${ASDF_DOWNLOAD_PATH}/.git" ]
	assert [ -f "${ASDF_DOWNLOAD_PATH}/koch.asdf-<YOUR TOOL LC>" ]
}

# @test "asdf_<YOUR TOOL ELC>_build" {
#   skip "TODO, but covered by integration tests & CI"
# }

# @test "asdf_<YOUR TOOL ELC>_install" {
#   skip "TODO, but covered by integration tests & CI"
# }
