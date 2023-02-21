# Zirconium Interpreter
# Developed by Razetime
# Original spec by RocketRace

# Short spec for development purposes:
# N←number of occupying drones
# K←number of attached stations
#  ⌾ Default Stations:
#    ∘ .←single drone to each
#    ∘ o←N drones to each
#    ∘ 0←zero drones to each
#    ∘ O←(⌊N÷K) drones to each
#    ∘ Q←N-1 drones to each
#    ∘ @←N=0 drones to each
#  ⌾ Exclusion Zone Stations('{', '~', '}'):
#    ∘ ?←Input a codepoint A, dispatch A drones to all
#    ∘ !←If N>0, end program
#    ∘ %←If N>0, print @+256|N
#    ∘ &←If N>0, print @+256|N (STDERR)
#    ∘ `←If N>0, print N
#    ∘ _←If N>0, dispatch •BQN•GetLine@ drones to all
#    ∘ ;←Pause program for N milliseconds
#  ⌾ Synthetic Stations('[', '=', ']' and `(())`)
#    Simplistic stack based language with N and K as args.
#    Syntax: <char> = <stack ops>

# helpers
Split←(⊢-˜+`×¬)∘=⊔⊢
SplitS←((⊢-˜¬×·+`»⊸<)∘∊˜⊔⊢)
DI←/○⥊⟜↕⟜≢ # n-D version of monadic /
_while_←{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}
Diff←¬∘∊/⊣
Inter←∊/⊣
Trw←{𝕩/˜¬∧`⌾⌽' '=𝕩}
Div←{·𝕊0:0;⌊𝕨÷𝕩} # division by zero returns zero

# constants
res←"~[]={}-+|/\" # reserved chars

Grid←{>((⌈´≠¨)↑¨⊢){Trw"    "(⊣∾"    "∾⊢)´'	'Split𝕩}¨(@+10)Split𝕩}

# lens interpreter
ILen←{
  𝕊 prg:
  n←⊑prg
  {⊑n∊res?•Show "Invalid lens name '"∾n∾"' in lens (("∾prg∾"))";@}
  prg↩2↓prg
  stack←⟨⟩
  tokens←{
    "+": +; "-": -; "*": ×; "/": Div;
    "=": =; "N": 'n'; "K": 'k';
    ∧´((𝕩≥'0')∧𝕩≤'9')?10⊸×⊸+˜´⌽𝕩-'0';
    •Show"Invalid lens instruction '"∾𝕩∾"' in '"∾prg∾"'",•Exit@
  }¨prg⊔˜1-˜+`(prg∊"+-*/=")∨((⊢∧⊢≠»)prg∊'0'+↕10)∨prg∊"NK"
  # dzaima
  n∾⊑⟨⟩ {
    n𝕊s: 
    •Type◶⟨
    !
    s∾<
    {s∾(⊑"nk"⊐𝕩)⊑⊣‿⊢}
    {𝕊f: (¯2↓s)∾<{𝕎F𝕏}´¯2↑s}
  ⟩ n}´⌽tokens
}

# lens parser
Lens←{
  l←(⊢∨0‿0⊸»˘)(≠↑·≠`"(("⊸⍷∨"))"⊸⍷)⌾⥊𝕩
  (∨´⥊l)◶⟨𝕩,⟨⟩⟩‿{⟨' '¨⌾((DI l)⊸⊑)𝕩,ILen¨"))(("SplitS 2↓¯2↓l/○⥊𝕩⟩}𝕩
}

# zone + station finder (general)
ZnS←{
  ⟨l‿t‿r,s,f,ex⟩ 𝕊 g:
  
  st←(DI g∊s) Diff ex
  {st≡⟨⟩?↕2‿0;
  ltr←l‿t‿r
    ret←⟨⟩
    {
      vz←⋈⊑𝕩
      {
        vz∾↩i_←vz Diff˜{
          b←{(𝕩≥0)∧○(∧´)𝕩<≢g}¨𝕩
          (b/𝕩)/˜⟨r‿t,l‿t,ltr,ltr⟩{∧´𝕨≠𝕩⊑g}¨○(b⊸/)𝕩
        }(⊏𝕩)+⟨0‿1,0‿¯1,1‿0,¯1‿0⟩
        (1↓𝕩)∾i_
      }_while_(0<≠)⋈⊑𝕩
      ret∾↩vz
      𝕩 Diff vz
    }_while_(0<≠)st
    ret(∊⟜s⊑⟜g)⊸/↩
    ret≍f⊏˜s⊐ret⊑g
  }
}
,
# zone ,function data
# w←N, ,𝕩←K
e←"?!%&`_;"
eF←⟨
  {𝕨>0?@-˜⍟(0⊸≢)•term.CharB@;0}
  {𝕨>0?"Program has ended."!𝕨>0;0}
  {𝕨>0?•term.OutRaw⋈@+256|𝕨,•term.Flush@,0;0}
  {𝕨>0?•term.ErrRaw@+256|𝕨,•term.Flush@,0;0}
  {𝕨>0?•term.OutRaw•Repr𝕨,•term.Flush@,0;0}
  {𝕨>0?(∧´≥⊸'0'∧≤⟜'9')◶⟨
      {•Show"Invalid number '"∾𝕩∾"'",•Exit@}
      10⊸×⊸+´
    ⟩•GetLine@; 0
  }
  {0⊣•Delay 𝕨÷1000}
⟩
p←".o0OQ@"
pF←⟨0<⊣, ⊣, 0, Div, 1-˜⊣, 0=⊣⟩
# stations grouped together
nb←⟨1‿1,1‿0,1‿¯1,0‿1,0‿¯1,¯1‿1,¯1‿0,¯1‿¯1⟩
Stn←{
  𝕊 a:
  sts←⟨⟩
  {
    vz←⋈⊑𝕩
    {
      vz∾↩i_←vz Diff˜∊⟜(⊏a)⊸/(⊏𝕩)+nb
      (1↓𝕩)∾i_
    }_while_(0<≠)⋈⊑𝕩
    sts∾↩⟨vz⟩
    𝕩 Diff vz
  }_while_(0<≠)⊏a
  sts≍{(1⊏a)⊏˜𝕩⊐˜⊏a}¨sts
}

# single station connections
Conn←{
  s‿g 𝕊 p:
  # nb←         ⟨1‿1,  1‿0,  1‿¯1, 0‿1,  0‿¯1,¯1‿1,¯1‿0,¯1‿¯1⟩
  t←"*[]={}~"⊸∾¨⟨"\#", "|v", "/#", "->", "-<", "/#", "|^", "\#"⟩
  ps←⟨⟩
  {
    𝕊 d‿c:
    f←+⟜d _while_{(0‿0≤𝕩+d)∧○(∧´)(𝕩+d)<≢g?⊑c∊˜g⊑˜𝕩+d;0}p
    {⊑c∊˜f⊑g?ps∾↩⋈d+f;@}
  }¨nb⋈¨t
  ps Inter s
}

# connections for all stations
Aco←{𝕨∾˜(</)˘((∾⟨∾⊏𝕨,𝕩⟩⊸Conn¨)¨∨´∘∊⌜⊢)⊏𝕨}

Run←{
  #{•Show 𝕩⊏˜⍋(⊑1⊸⊑)˘𝕩}¨{
  {
    n←((≠𝕩)⥊0){i‿·‿f‿d 𝕊 𝕩:(+´f{𝕩𝕎≠i}¨d)⊸+⌾(i⊸⊏)𝕩}˝𝕩
    n∾˜˘¯1↓˘𝕩 
  #}⍟(↕4) ⍉∾⟜(0¨∘⊏)𝕩
  }_while_ 1 ⍉∾⟜(0¨∘⊏)𝕩
  @
}

# interpreter
In←{
  ng‿l←Lens Grid 𝕩
  l∾↩𝕨
  met←⟨"[=]",⊑¨l,1⊑¨l,⟨⟩⟩Zns ng
  exc←⟨"{~}",e,eF,⊏met⟩Zns ng
  pi←(DI ng∊p)Diff met∾○⊏exc
  pur←pi≍pF⊏˜p⊐pi⊑ng
  a←met∾˘exc∾˘pur 
  Run (Stn a) Aco ng # run the parsed graph
}

{f‿h:(ILen¨•FLines h)In•FChars f;⟨⟩In•FChars⊑𝕩}•args
