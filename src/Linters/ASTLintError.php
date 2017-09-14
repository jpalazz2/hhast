<?hh // strict
/**
 * Copyright (c) 2016, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional
 * grant of patent rights can be found in the PATENTS file in the same
 * directory.
 *
 */

namespace Facebook\HHAST\Linters;

use type Facebook\HHAST\EditableSyntax;
use function Facebook\HHAST\find_position;

class ASTLintError<
  Tnode as EditableSyntax,
  Tlinter as ASTLinter<Tnode>
> extends LintError implements FixableLintError {

  <<__Override>>
  public function __construct(
    protected Tlinter $linter,
    string $description,
    private Tnode $node,
  ) {
    parent::__construct($linter, $description);
  }

  final public function getBlameNode(): Tnode {
    return $this->node;
  }

  final public function getPosition(): (int, int) {
    return find_position($this->linter->getAST(), $this->getBlameNode());
  }

  <<__Override>>
  final public function getBlameCode(): string {
    return $this->node->getCode();
  }

  <<__Memoize, __Override>>
  final public function getPrettyBlameCode(): string {
    return $this->linter->getPrettyNode($this->node)->getCode();
  }

  final public function isFixable(): bool {
    return $this->linter instanceof AutoFixingASTLinter;
  }

  final public function getReadableFix(): (string, string) {
    $linter = $this->linter;
    invariant(
      $linter instanceof AutoFixingASTLinter,
      "Can't render fix for unfixable lint error",
    );
    return tuple(
      $this->getPrettyBlameCode(),
      $linter->getPrettyNode(
        $linter->getFixedNode($this->node),
      )->getCode(),
    );
  }
}
