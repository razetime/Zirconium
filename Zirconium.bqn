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
    "+": +; "-": -; "*": ×; "/": ÷;
    "=": =; "N": 'n'; "K": 'k';
    ∧´((𝕩≥'0')∧𝕩≤'9')?10⊸×⊸+´𝕩-'0';
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
  ⟨' '¨⌾((DI l)⊸⊑)𝕩,ILen¨"))(("SplitS 2↓¯2↓l/○⥊𝕩⟩
}

# zone + station finder (general)
ZnS←{
  ⟨l‿t‿r,s,f,ex⟩ 𝕊 g:
  ltr←l‿t‿r
  ret←⟨⟩
  {
    vz←⋈⊑𝕩
    {
      vz∾↩i_←vz Diff˜{
        b←{(𝕩≥0)∧○(∧´)𝕩<≢g}¨𝕩
        (b/𝕩)/˜⟨r⊸≠,l⊸≠,¬·⊑∊⟜ltr,¬·⊑∊⟜ltr⟩{𝕎𝕩⊑g}¨○(b⊸/)𝕩
      }(⊏𝕩)+⟨0‿1,0‿¯1,1‿0,¯1‿0⟩
      (1↓𝕩)∾i_
    }_while_(0<≠)⋈⊑𝕩
    ret∾↩vz
    𝕩 Diff vz
  }_while_(0<≠)(DI g∊s) Diff ex
  ret(∊⟜s⊑⟜g)⊸/↩
  ret≍f⊏˜s⊐ret⊑g
}

# zone function data
e←"?!%&`_;"
eF←⟨
  {𝕊:@-˜⊑•GetLine@}
  {"Program has ended."!𝕨>0}
  {0⊣stdout∾↩@+256|𝕨}
  {0⊣stderr∾↩@+256|𝕨}
  {0⊣stdout∾↩•Show 𝕨}
  {𝕊:(∧´≥⊸'0'∧≤⟜'9')◶⟨
      {•Show"Invalid number '"∾𝕩∾"'",•Exit@}
      10⊸×⊸+´
    ⟩•GetLine@
  }
  {0⊣•Delay 𝕨÷1000}
⟩
p←".o0OQ@"
pF←⟨0>˜⊣, ⊣, 0⊸⊣, ⌊∘÷, 1-˜⊣, 0=⊣⟩
# table of all stations in a grid, grouped together
Stnst←{
  ng‿l←Lens 𝕩
  ls←⊑¨l
  met←⟨"[=]",ls,1⊑¨l,⟨⟩⟩Zns ng
  exc←⟨"{~}",e,eF,⊏met⟩Zns ng
  pi←(DI ng∊p)Diff met∾○⊏exc
  pur←pi≍pF⊏˜p⊐pi⊑ng
  a←met∾˘exc∾˘pur 
  sts←⟨⟩
  {
    vz←⋈⊑𝕩
    {
      vz∾↩i_←vz Diff˜∊⟜(⊏a)⊸/(⊏𝕩)+⟨1‿1,1‿0,1‿¯1,0‿1,0‿¯1,¯1‿1,¯1‿0,¯1‿¯1⟩
      (1↓𝕩)∾i_
    }_while_(0<≠)⋈⊑𝕩
    sts∾↩⟨vz⟩
    𝕩 Diff vz
  }_while_(0<≠)⊏a
  sts≍{(1⊏a)⊏˜𝕩⊐˜⊏a}¨sts
}
  

stdout←""
stderr←""

g←Grid"    ======================================
@>@[H>d.>l>l>l...>,>_>r.....>l...>r>l>d>_.]
    ======================================
    | |  | | |    | | |      |    | | | |
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   {% %  % % %    % % %      %    % % % %}
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
((H=1N0=-72*)) ((d=1N0=-100*)) ((l=1N0=-108*))
((,=1N0=-44*)) ((r=1N0=-114*)) ((_=1N0=-32*))"

# testing function
T←{
  ng‿l←Lens 𝕩
  •Show ng
  •Show l
  ls←⊑¨l
  # met←⟨"[=]",ls,1⊑¨l,⟨⟩⟩ Zns ng
  # exc←⟨"{~}",e,eF,⊏met⟩ Zns ng
  # pur←(DI ng∊".o0OQ@")Diff met∾○∾exc
  Stnst 𝕩
}

