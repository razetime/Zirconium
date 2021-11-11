# Zirconium Interpreter
# Developed by Razetime
# Original spec by RocketRace

# Short spec for development purposes:
# N ← number of occupying drones
# K ← number of attached stations
#  ⌾ Default Stations:
#    ∘ . ← single drone to each
#    ∘ o ← N drones to each
#    ∘ 0 ← zero drones to each
#    ∘ O ← (⌊N÷K) drones to each
#    ∘ Q ← N-1 drones to each
#    ∘ @ ← N=0 drones to each
#  ⌾ Exclusion Zone Stations('{', '~', '}'):
#    ∘ ? ← Input a codepoint A, dispatch A drones to all
#    ∘ ! ← If N>0, end program
#    ∘ % ← If N>0, print @+256|N
#    ∘ & ← If N>0, print @+256|N (STDERR)
#    ∘ ` ← If N>0, print N
#    ∘ _ ← If N>0, dispatch •BQN•GetLine@ drones to all
#    ∘ ; ← Pause program for N milliseconds
#  ⌾ Synthetic Stations('[', '=', ']')
#    Simplistic stack based language with N and K as args.
#    Syntax: <letter> = <stack ops>

# Helpers:
Split ← (⊢-˜+`×¬)∘=⊔⊢
TwoD ← /○⥊⟜↕⟜≢ # 2D version of monadic /
_while_ ← {𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}
Diff ← ¬∘∊/⊣

# Hello World program for test
test ←"    ======================================
@>@[H>d.>l>l>l...>,>_>r.....>l...>r>l>d>_.]
    ======================================
    | |  | | |    | | |      |    | | | |
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   {% %  % % %    % % %      %    % % % %}
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
((H=1N0=-72*)) ((d=1N0=-100*)) ((l=1N0=-108*))
((,=1N0=-44*)) ((r=1N0=-114*)) ((_=1N0=-32*))"

station ← {
  name ⇐ '0'
  drones ⇐ 0
  n ⇐ 0
  k ⇐ 0
  Func ⇐ 0⊸⊣
}
stdout ← ""
stderr ← ""

grid ← >{(⌈´≠¨𝕩)↑¨𝕩}(@+10) Split test # program grid. This will be modified later
stations ← ⟨⟩

# Pure stations:
defSt ← ".o0OQ@"
defFns ← ⟨0>˜⊣, ⊣, 0⊸⊣, ⌊∘÷, 1-˜⊣, 0=⊣⟩

# Zone detection via flood fill
# pad inds with zeroes on all sides
•Show
dels ← ⟨0‿¯1, 1‿0, 0‿1⟩

# Zones:
FindZones ← {
  𝕊 chars: #border chars.
  chs ← 2↑ chars
  inds ← TwoD {¯1‿¯1⌽(2+≢𝕩)↑𝕩}{<(¬⊑chs∊˜⊑𝕩)∧2≤+´chs∊˜0‿1‿3⊏𝕩}∘⥊⎉2 3‿3 ↕ grid
  zones ← ⟨⟩ # Holds all zone points.
  {
    zone ← ⟨⟩
    corner ← ⊑𝕩
    {
      zone ∾↩ 𝕩
      new ← ⍷∾{dels +<𝕩}¨𝕩
      ("Invalid station with top left corner"∾○<corner)!¬∨´∨´¨(<≢ grid)= new
      new /˜↩ ¬chars ∊˜ new ⊑¨< grid
      new Diff zone
    } _while_ { 0≠≠𝕩 } ⟨corner⟩
    zones ∾↩ ⟨zone⟩
    𝕩 Diff zone
  } _while_ { 0≠≠𝕩 } inds
  zones
}
zoneCats ← FindZones¨ ⟨"~{}", "=[]"⟩
# •Show zoneCats

# Exclusion zones:
exSt ← "?!%&`_;"
exFns ← ⟨{𝕨𝕊𝕩:@-˜⊑•GetLine@}, {"Program has ended."!𝕨>0}, {0⊣stdout∾↩@+256|𝕨}, {0⊣stderr∾↩@+256|𝕨}, {0⊣stdout∾↩•Show 𝕨}, {𝕨𝕊𝕩:•BQN•GetLine@}, {0⊣•Delay 𝕨÷1000}⟩



# Lenses:
# (×∘≠¨/⊢)(⊢-˜¬×+`)⊸⊔
lenses ← (1↓¯1⊸↓)¨(×∘≠¨/⊢)∾(((¬·<0∾+`)˘("(("⊸⍷-"))"⊸⍷)){𝕨(⊢-˜¬×+`)⊸⊔𝕩}¨<˘) grid
•Show lenses

StackLang ← {
  𝕊 prg:
  stack ← ⟨⟩
  tokens ← {
    "+": +;
    "-": -;
    "*": ×;
    "/": ÷;
    "=": =;
    "N": 'n';
    "K": 'k';
    •BQN 𝕩    # add a descriptive error message for non-number later
  }¨prg⊔˜1-˜+`(prg∊"+-*/=")∨((⊢∧⊢≠»)prg∊'0'+↕10)∨prg∊"NK"
  { # borrowed from dzaima
    ⊑⟨⟩ {
      n𝕊s: 
      •Type◶⟨
      !
      s∾<
      {s∾(⊑"nk"⊐𝕩)⊑⊣‿⊢}
      {𝕊f: (¯2↓s)∾<{𝕎F𝕏}´¯2↑s}
    ⟩ n}´⌽ 𝕩
  } tokens
}

{
  f ← StackLang 2↓𝕩
  •Show ⟨𝕩, 0 F 0, F⟩  
}¨lenses
