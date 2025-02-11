/*
 *  Copyright (c) 2017-present, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the MIT license found in the
 *  LICENSE file in the root directory of this source tree.
 *
 */

namespace Facebook\HHAST\__Private;

use namespace Facebook\TypeAssert;
use type Facebook\CLILib\CLIBase;
use namespace Facebook\CLILib\CLIOptions;
use namespace HH\Lib\Keyset;

final class CodegenCLI extends CLIBase {
  const type TSchema = Schema\TSchema;

  private ?string $hhvmPath = null;
  private bool $rebuildRelationships = false;
  private bool $updateLatestBreakingVersion = false;
  private bool $dontUpdateAST = false;

  <<__Override>>
  protected function getSupportedOptions(): vec<CLIOptions\CLIOption> {
    return vec[
      CLIOptions\with_required_string(
        $path ==> {
          $this->hhvmPath = $path;
        },
        'Path to HHVM source tree',
        '--hhvm-path',
      ),
      CLIOptions\flag(
        () ==> {
          $this->rebuildRelationships = true;
        },
        'Update inferred relationships based on the HHVM and Hack tests; requires --hhvm-path',
        '--rebuild-relationships',
      ),
      CLIOptions\flag(
        () ==> {
          $this->updateLatestBreakingVersion = true;
        },
        'Update `latest_breaking_change_version.hack` to mark the latest version as a breaking change.',
        '--update-latest-breaking-version',
      ),
      CLIOptions\flag(
        () ==> {
          $this->dontUpdateAST = true;
        },
        'Skip AST class generation.',
        '--dont-update-ast',
      ),
    ];
  }

  <<__Override>>
  public async function mainAsync(): Awaitable<int> {
    $generators = Keyset\union(
      $this->dontUpdateAST
        ? keyset[]
        : keyset[
            CodegenNodeFromJSON::class,
            CodegenTokenFromData::class,
            CodegenTriviaFromJSON::class,
            CodegenTokens::class,
            CodegenTrivia::class,
            CodegenSyntax::class,
            CodegenVersion::class,
          ],
      $this->updateLatestBreakingVersion
        ? keyset[CodegenLastestBreakingVersion::class]
        : keyset[],
    );
    $schema = $this->getSchema();
    $rebuild_relationships = $this->rebuildRelationships;
    if ($rebuild_relationships) {
      $hhvm = $this->hhvmPath;
      if ($hhvm === null) {
        await $this->getStderr()->writeAllAsync(
          "--hhvm-path is required when rebuilding relationships.\n",
        );
        return 1;
      }
      $relationships = dict[];
      foreach ($generators as $generator) {
        (new $generator($schema, $relationships))->withoutHackfmt()->generate();
      }
      (new CodegenRelations($hhvm, $schema))->generate();
    }

    $relationships = CodegenRelations::getInferredRelationships();
    foreach ($generators as $generator) {
      (new $generator($schema, $relationships))->generate();
    }

    return 0;
  }

  <<__Memoize>>
  private function getSchema(): self::TSchema {
    $json = \file_get_contents(\realpath(\getcwd()).'/codegen/schema.json');
    $array = \json_decode(
      $json, /* associative array = */
      true, /* depth = */
      512,
      \JSON_FB_HACK_ARRAYS,
    );

    return TypeAssert\matches_type_structure(
      type_structure(self::class, 'TSchema'),
      $array,
    );
  }
}
