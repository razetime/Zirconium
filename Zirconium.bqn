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
    ∧´((𝕩≥'0')∧𝕩≤'9')?10⊸×⊸+´⌽𝕩-'0';
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

# zone finder (general)
Zones←{
  ⟨l‿t‿r,s,ex⟩ 𝕊 g:
  ltr←l‿t‿r
  ret←⟨⟩
  v←⟨⟩
  {
    •Show "vz"⋈ vz←⋈⊑𝕩
    {
      vz∾↩i_←vz Diff˜{
        b←{(𝕩≥0)∧○(∧´)𝕩<≢g}¨𝕩
        •Show (b/𝕩)/˜⟨r⊸≠,l⊸≠,¬·⊑∊⟜ltr,¬·⊑∊⟜ltr⟩{𝕎𝕩⊑g}¨○(b⊸/)𝕩
      }(•Show ⊏𝕩)+⟨0‿1,0‿¯1,1‿0,¯1‿0⟩
      (1↓𝕩)∾i_
    }_while_(0<≠)⋈⊑𝕩
    ret∾↩⟨vz⟩
    𝕩 Diff vz
  }_while_(0<≠)(DI •Show g∊s) Diff ex
  ret
}

# Values for the Program Graph
names←⟨⟩
dCounts←⟨⟩
nVals←⟨⟩
kVals←⟨⟩
funcVals←⟨⟩
stdout←""
stderr←""

# Pure stations:
p←".o0OQ@"
pF←⟨0>˜⊣, ⊣, 0⊸⊣, ⌊∘÷, 1-˜⊣, 0=⊣⟩

# Exclusion zones:
e←"?!%&`_;"
eF←⟨
  {𝕨𝕊𝕩:@-˜⊑•GetLine@}
  {"Program has ended."!𝕨>0}
  {0⊣stdout∾↩@+256|𝕨}
  {0⊣stderr∾↩@+256|𝕨}
  {0⊣stdout∾↩•Show 𝕨}
  {𝕨𝕊𝕩:•BQN•GetLine@}
  {0⊣•Delay 𝕨÷1000}
⟩

deltas←⟨1‿1,1‿0,1‿¯1,0‿1,0‿¯1,¯1‿1,¯1‿0,¯1‿¯1⟩

GetStations←{
  𝕊 points‿chars‿fns:
  stations←⟨⟩
  curr←⋈⊑points
  { # get each station and put it in stations
    𝕊𝕩:
    cch←curr⊑grid

    { # Flood fill to bind stations together.
      ngb←(∾<˘deltas+⌜𝕩) Diff 𝕩
      ngb ↩ (cch=ngb⊏grid) / ngb
      curr ∾↩ ngb
      ngb
    } _while_ { 𝕩≢⟨⟩ } curr

    { # Now get the connections.
      (∾⟜"*[]={}~"¨⟨"\#", "|^", "/#", "->", "-<", "/#", "|v", "\#"⟩){𝕨∊˜𝕩⊏grid}¨deltas+<𝕩
    }¨curr
    stations ∾↩ ⟨cch, curr, (⊑cch⊐chars)⊑fns, 0, 0⟩
     points ↩ points Diff curr

    # reset curr for next iteration
    curr ↩ ⊑points

  } _while_ { 𝕊𝕩: points ≢ ⟨⟩}
}


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
  met←⟨"[=]",⊑¨l,⟨⟩⟩ Zones ng
  exc←⟨"{~}",e,∾met⟩ Zones ng
  met≍○<exc
}
