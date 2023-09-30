#!/usr/bin/env hhvm
/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace Facebook\HHAST\__Private;

<<__EntryPoint>>
async function hhast_dump_main_async(): Awaitable<noreturn> {
  if (!\HH\Facts\enabled()) {
    \fprintf(
      \STDERR,
      "FactsDB must be enabled for hhast to autoload properly.\n",
    );
    exit(1);
  }

  $result = await DumpCLI::runAsync();
  exit($result);
}
