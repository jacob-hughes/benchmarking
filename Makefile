# Copyright (c) 2020 King's College London
# Created by the Software Development Team <http://soft-dev.org/>
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0>, or the MIT license <LICENSE-MIT
# or http://opensource.org/licenses/MIT>, at your option. This file may not be
# copied, modified, or distributed except according to those terms.

YKSOM_DIR=yksom
RUSTC_BOEHM_DIR=rustc_boehm

YKSOM_BASELINE=yksom_baseline
YKSOM_CUSTOM_RUSTC=yksom_custom_rustc

PATHS_SH=paths.sh

TOP_DIR=`pwd`

KRUN_DIR=krun
KRUN=${KRUN_DIR}/krun.py
KRUN_VERSION=d38c0724c46724b386a421ca10b396d5891a55bb
LIBKRUNTIME=${KRUN_DIR}/libkrun/libkruntime.so

PEXECS=10
INPROC_ITERS=2000

TEST_PEXECS=1
TEST_INPROC_ITERS=3

.PHONY: setup
setup: ${YKSOM_DIR} ${RUSTC_BOEHM_DIR} ${LIBKRUNTIME} ${YKSOM_BASELINE} ${YKSOM_CUSTOM_RUSTC}

${PATHS_SH}:
	echo YKSOM_DIR=${TOP_DIR}/${YKSOM_DIR} >> ${PATHS_SH}

${YKSOM_DIR}:
	git clone https://github.com/softdevteam/yksom

${RUSTC_BOEHM_DIR}:
	git clone https://github.com/softdevteam/rustc_boehm

${YKSOM_BASELINE}:
	cd ${YKSOM_DIR} && cargo +nightly build --release --target-dir=${YKSOM_BASELINE}

${YKSOM_CUSTOM_RUSTC}:
	cd rustc_boehm && ./x.py build --stage 1 && rustup toolchain link rustc_boehm build/x86_64-unknown-linux-gnu/stage1
	cd ${YKSOM_DIR} && cargo +rustc_boehm build --release --features "rustc_boehm" --target-dir=${YKSOM_CUSTOM_RUSTC}

.PHONY: krun
krun: ${LIBKRUNTIME}

${KRUN}:
	git clone https://github.com/softdevteam/krun ${KRUN_DIR}
	cd ${KRUN_DIR} && git checkout ${KRUN_VERSION}

${LIBKRUNTIME}: ${KRUN}
	cd ${KRUN_DIR} && ${MAKE} NO_MSRS=1

.PHONY: clean
clean: clean-krun-results clean-temp-files
	rm -rf ${YKSOM_DIR} ${RUSTC_BOEHM_DIR}

clean-krun-results:
	rm -rf experiment_results.json.bz2 experiment.log experiment.manifest \
		experiment_envlogs

# The suites have a tendency to write stuff all over the experiment dir.
clean-temp-files:
	rm -rf page_rank* scratch target
