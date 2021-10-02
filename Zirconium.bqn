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

grid ← >{(⌈´≠¨𝕩)↑¨𝕩}(@+10) Split test # program grid. This will be modified later
stations ← ⟨⟩

# Zone detection via flood fill
# pad inds with zeroes on all sides
•Show inds ← TwoD •Show {¯1‿¯1⌽(2+≢𝕩)↑𝕩}{<(¬⊑"[="∊˜⊑𝕩)∧2≤+´"[="∊˜0‿1‿3⊏𝕩}∘⥊⎉2 3‿3 ↕ grid
dels ← ⟨0‿¯1, 1‿0, 0‿1⟩
zones ← ⟨⟩ # Holds all zone points.

{
  zone ← ⟨⟩
  corner ← ⊑𝕩
  {
    zone ∾↩ 𝕩
    •Show new ← ⍷∾{dels +<𝕩}¨𝕩
    ("Invalid station with top left corner"∾○<corner)!¬∨´∨´¨(<≢ grid)= new
    new /˜↩ ¬"=[]" ∊˜ new ⊑¨< grid
    •Show new
    new Diff zone
  } _while_ { 0≠≠𝕩 } ⟨corner⟩
  zones ∾↩ ⟨zone⟩
  𝕩 Diff zone
} _while_ { 0≠≠𝕩 } inds
•Show zone
