<?hh // strict
/**
 * This file is generated. Do not modify it manually!
 *
 * @generated SignedSource<<e6783ed5ce17e0a31604a2e5ee2b5ff7>>
 */
namespace Facebook\HHAST;
use namespace Facebook\TypeAssert;

final class SimpleTypeSpecifier extends EditableNode {

  private EditableNode $_specifier;

  public function __construct(EditableNode $specifier) {
    parent::__construct('simple_type_specifier');
    $this->_specifier = $specifier;
  }

  <<__Override>>
  public static function fromJSON(
    dict<string, mixed> $json,
    int $position,
    string $source,
  ): this {
    $specifier = EditableNode::fromJSON(
      /* UNSAFE_EXPR */ $json['simple_type_specifier'],
      $position,
      $source,
    );
    $position += $specifier->getWidth();
    return new self($specifier);
  }

  <<__Override>>
  public function getChildren(): KeyedTraversable<string, EditableNode> {
    return dict['specifier' => $this->_specifier];
  }

  <<__Override>>
  public function rewriteDescendants(
    self::TRewriter $rewriter,
    ?Traversable<EditableNode> $parents = null,
  ): this {
    $parents = $parents === null ? vec[] : vec($parents);
    $parents[] = $this;
    $specifier = $this->_specifier->rewrite($rewriter, $parents);
    if ($specifier === $this->_specifier) {
      return $this;
    }
    return new self($specifier);
  }

  public function getSpecifierUNTYPED(): EditableNode {
    return $this->_specifier;
  }

  public function withSpecifier(EditableNode $value): this {
    if ($value === $this->_specifier) {
      return $this;
    }
    return new self($value);
  }

  public function hasSpecifier(): bool {
    return !$this->_specifier->isMissing();
  }

  /**
   * @returns NameToken | ArrayToken | VoidToken | IntToken | StringToken |
   * QualifiedNameToken | BoolToken | DoubleToken | FloatToken | DictToken |
   * MixedToken | ArraykeyToken | VecToken | KeysetToken | SelfToken |
   * ResourceToken | XHPClassNameToken | ThisToken | ParentToken | NumToken |
   * VarrayToken | DarrayToken | NoreturnToken
   */
  public function getSpecifier(): EditableToken {
    return TypeAssert\instance_of(EditableToken::class, $this->_specifier);
  }
}
