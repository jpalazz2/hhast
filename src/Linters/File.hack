/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace Facebook\HHAST\Linters;

final class File {
  private function __construct(
    private string $path, private string $contents, private bool $isDirty) {
  }

  public function isDirty(): bool {
    return $this->isDirty;
  }

  public function getPath(): string {
    return $this->path;
  }

  public function getContents(): string {
    return $this->contents;
  }

  public function withContents(string $contents): this {
    if ($contents === $this->contents) {
      return $this;
    }
    return new self($this->path, $contents, /* dirty = */ true);
  }

  public static function fromPath(string $path): this {
    return new File($path, \file_get_contents($path), /* dirty = */ false);
  }

  public static function fromPathAndContents(string $path, string $contents): this {
    return new File($path, $contents, /* dirty = */ true);
  }

  <<__Memoize>>
  public function getHash(): string {
    return \sodium_crypto_generichash(
      $this->contents,
      \Facebook\HHAST\SCHEMA_VERSION,
    );
  }
}
