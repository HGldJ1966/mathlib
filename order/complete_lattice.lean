/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

Theory of complete lattices.
-/
import order.bounded_lattice data.set.basic

set_option old_structure_cmd true

universes u v w w₂
variables {α : Type u} {β : Type v} {ι : Sort w} {ι₂ : Sort w₂}

namespace lattice

class has_Sup (α : Type u) := (Sup : set α → α)
class has_Inf (α : Type u) := (Inf : set α → α)
def Sup [has_Sup α] : set α → α := has_Sup.Sup
def Inf [has_Inf α] : set α → α := has_Inf.Inf

class complete_lattice (α : Type u) extends bounded_lattice α, has_Sup α, has_Inf α :=
(le_Sup : ∀s, ∀a∈s, a ≤ Sup s)
(Sup_le : ∀s a, (∀b∈s, b ≤ a) → Sup s ≤ a)
(Inf_le : ∀s, ∀a∈s, Inf s ≤ a)
(le_Inf : ∀s a, (∀b∈s, a ≤ b) → a ≤ Inf s)

def supr [complete_lattice α] (s : ι → α) : α := Sup {a : α | ∃i : ι, a = s i}
def infi [complete_lattice α] (s : ι → α) : α := Inf {a : α | ∃i : ι, a = s i}

notation `⨆` binders `, ` r:(scoped f, supr f) := r
notation `⨅` binders `, ` r:(scoped f, infi f) := r

section
open set
variables [complete_lattice α] {s t : set α} {a b : α}

@[ematch] theorem le_Sup : a ∈ s → a ≤ Sup s         := complete_lattice.le_Sup s a

theorem Sup_le : (∀b∈s, b ≤ a) → Sup s ≤ a := complete_lattice.Sup_le s a

@[ematch] theorem Inf_le : a ∈ s → Inf s ≤ a         := complete_lattice.Inf_le s a

theorem le_Inf : (∀b∈s, a ≤ b) → a ≤ Inf s := complete_lattice.le_Inf s a

theorem le_Sup_of_le (hb : b ∈ s) (h : a ≤ b) : a ≤ Sup s :=
le_trans h (le_Sup hb)

theorem Inf_le_of_le (hb : b ∈ s) (h : b ≤ a) : Inf s ≤ a :=
le_trans (Inf_le hb) h

theorem Sup_le_Sup (h : s ⊆ t) : Sup s ≤ Sup t :=
Sup_le (assume a, assume ha : a ∈ s, le_Sup $ h ha)

theorem Inf_le_Inf (h : s ⊆ t) : Inf t ≤ Inf s :=
le_Inf (assume a, assume ha : a ∈ s, Inf_le $ h ha)

@[simp] theorem Sup_le_iff : Sup s ≤ a ↔ (∀b ∈ s, b ≤ a) :=
⟨assume : Sup s ≤ a, assume b, assume : b ∈ s,
  le_trans (le_Sup ‹b ∈ s›) ‹Sup s ≤ a›,
  Sup_le⟩

@[simp] theorem le_Inf_iff : a ≤ Inf s ↔ (∀b ∈ s, a ≤ b) :=
⟨assume : a ≤ Inf s, assume b, assume : b ∈ s,
  le_trans ‹a ≤ Inf s› (Inf_le ‹b ∈ s›),
  le_Inf⟩

-- how to state this? instead a parameter `a`, use `∃a, a ∈ s` or `s ≠ ∅`?
theorem Inf_le_Sup (h : a ∈ s) : Inf s ≤ Sup s :=
by have := le_Sup h; finish
--Inf_le_of_le h (le_Sup h)

-- TODO: it is weird that we have to add union_def
theorem Sup_union {s t : set α} : Sup (s ∪ t) = Sup s ⊔ Sup t :=
le_antisymm 
  (by finish) 
  (sup_le (Sup_le_Sup $ subset_union_left _ _) (Sup_le_Sup $ subset_union_right _ _))

/- old proof:
le_antisymm
  (Sup_le $ assume a h, or.rec_on h (le_sup_left_of_le ∘ le_Sup) (le_sup_right_of_le ∘ le_Sup))
  (sup_le (Sup_le_Sup $ subset_union_left _ _) (Sup_le_Sup $ subset_union_right _ _))
-/

theorem Sup_inter_le {s t : set α} : Sup (s ∩ t) ≤ Sup s ⊓ Sup t :=
by finish
/-
  Sup_le (assume a ⟨a_s, a_t⟩, le_inf (le_Sup a_s) (le_Sup a_t))
-/

theorem Inf_union {s t : set α} : Inf (s ∪ t) = Inf s ⊓ Inf t :=
le_antisymm 
  (le_inf (Inf_le_Inf $ subset_union_left _ _) (Inf_le_Inf $ subset_union_right _ _))
  (by finish)

/- old proof:
le_antisymm
  (le_inf (Inf_le_Inf $ subset_union_left _ _) (Inf_le_Inf $ subset_union_right _ _))
  (le_Inf $ assume a h, or.rec_on h (inf_le_left_of_le ∘ Inf_le) (inf_le_right_of_le ∘ Inf_le))
-/

theorem le_Inf_inter {s t : set α} : Inf s ⊔ Inf t ≤ Inf (s ∩ t) :=
by finish
/-
le_Inf (assume a ⟨a_s, a_t⟩, sup_le (Inf_le a_s) (Inf_le a_t))
-/

@[simp] theorem Sup_empty : Sup ∅ = (⊥ : α) :=
le_antisymm (by finish) (by finish)
-- le_antisymm (Sup_le (assume _, false.elim)) bot_le

@[simp] theorem Inf_empty : Inf ∅ = (⊤ : α) :=
le_antisymm (by finish) (by finish)
--le_antisymm le_top (le_Inf (assume _, false.elim))

@[simp] theorem Sup_univ : Sup univ = (⊤ : α) :=
le_antisymm (by finish) (le_Sup ⟨⟩) -- finish fails because ⊤ ≤ a simplifies to a = ⊤
--le_antisymm le_top (le_Sup ⟨⟩)

@[simp] theorem Inf_univ : Inf univ = (⊥ : α) :=
le_antisymm (Inf_le ⟨⟩) bot_le

-- TODO(Jeremy): get this automatically
@[simp] theorem Sup_insert {a : α} {s : set α} : Sup (insert a s) = a ⊔ Sup s :=
have Sup {b | b = a} = a,
  from le_antisymm (Sup_le $ assume b b_eq, b_eq ▸ le_refl _) (le_Sup rfl),
calc Sup (insert a s) = Sup {b | b = a} ⊔ Sup s : Sup_union
                  ... = a ⊔ Sup s : by rw [this]

@[simp] theorem Inf_insert {a : α} {s : set α} : Inf (insert a s) = a ⊓ Inf s :=
have Inf {b | b = a} = a,
  from le_antisymm (Inf_le rfl) (le_Inf $ assume b b_eq, b_eq ▸ le_refl _),
calc Inf (insert a s) = Inf {b | b = a} ⊓ Inf s : Inf_union
                  ... = a ⊓ Inf s : by rw [this]


@[simp] theorem Sup_singleton {a : α} : Sup {a} = a :=
by finish [singleton_def]
--eq.trans Sup_insert $ by simp

@[simp] theorem Inf_singleton {a : α} : Inf {a} = a :=
by finish [singleton_def]
--eq.trans Inf_insert $ by simp

end


/- supr & infi -/

section
open set
variables [complete_lattice α] {s t : ι → α} {a b : α}

-- TODO: this declaration gives error when starting smt state
--@[ematch]
theorem le_supr (s : ι → α) (i : ι) : s i ≤ supr s :=
le_Sup ⟨i, rfl⟩

@[ematch] theorem le_supr' (s : ι → α) (i : ι) : (: s i ≤ supr s :) :=
le_Sup ⟨i, rfl⟩

/- TODO: this version would be more powerful, but, alas, the pattern matcher
   doesn't accept it.
@[ematch] theorem le_supr' (s : ι → α) (i : ι) : (: s i :) ≤ (: supr s :) :=
le_Sup ⟨i, rfl⟩
-/

theorem le_supr_of_le (i : ι) (h : a ≤ s i) : a ≤ supr s :=
le_trans h (le_supr _ i)

theorem supr_le (h : ∀i, s i ≤ a) : supr s ≤ a :=
Sup_le $ assume b ⟨i, eq⟩, eq.symm ▸ h i

theorem supr_le_supr (h : ∀i, s i ≤ t i) : supr s ≤ supr t :=
supr_le $ assume i, le_supr_of_le i (h i)

theorem supr_le_supr2 {t : ι₂ → α} (h : ∀i, ∃j, s i ≤ t j) : supr s ≤ supr t :=
supr_le $ assume j, exists.elim (h j) le_supr_of_le

theorem supr_le_supr_const (h : ι → ι₂) : (⨆ i:ι, a) ≤ (⨆ j:ι₂, a) :=
supr_le $ le_supr _ ∘ h

@[simp] theorem supr_le_iff : supr s ≤ a ↔ (∀i, s i ≤ a) :=
⟨assume : supr s ≤ a, assume i, le_trans (le_supr _ _) this, supr_le⟩

-- TODO: finish doesn't do well here.
@[congr] theorem supr_congr_Prop {p q : Prop} {f₁ : p → α} {f₂ : q → α}
  (pq : p ↔ q) (f : ∀x, f₁ (pq.mpr x) = f₂ x) : supr f₁ = supr f₂ :=
le_antisymm
  (supr_le_supr2 $ assume j, ⟨pq.mp j, le_of_eq $ f _⟩)
  (supr_le_supr2 $ assume j, ⟨pq.mpr j, le_of_eq $ (f j).symm⟩)

theorem infi_le (s : ι → α) (i : ι) : infi s ≤ s i :=
Inf_le ⟨i, rfl⟩

@[ematch] theorem infi_le' (s : ι → α) (i : ι) : (: infi s ≤ s i :) :=
Inf_le ⟨i, rfl⟩

example {f : β → α} (b : β) : (⨅ x, f x) ≤ f b :=
begin [smt]
  eblast
end

/- I wanted to see if this would help for infi_comm; it doesn't.
@[ematch] theorem infi_le₂' (s : ι → ι₂ → α) (i : ι) (j : ι₂): (: ⨅ i j, s i j :) ≤ (: s i j :) :=
begin
  transitivity,
  apply (infi_le (λ i, ⨅ j, s i j) i),
  apply infi_le
end
-/

theorem infi_le_of_le (i : ι) (h : s i ≤ a) : infi s ≤ a :=
le_trans (infi_le _ i) h

theorem le_infi (h : ∀i, a ≤ s i) : a ≤ infi s :=
le_Inf $ assume b ⟨i, eq⟩, eq.symm ▸ h i

theorem infi_le_infi (h : ∀i, s i ≤ t i) : infi s ≤ infi t :=
le_infi $ assume i, infi_le_of_le i (h i)

theorem infi_le_infi2 {t : ι₂ → α} (h : ∀j, ∃i, s i ≤ t j) : infi s ≤ infi t :=
le_infi $ assume j, exists.elim (h j) infi_le_of_le

theorem infi_le_infi_const (h : ι₂ → ι) : (⨅ i:ι, a) ≤ (⨅ j:ι₂, a) :=
le_infi $ infi_le _ ∘ h

@[simp] theorem le_infi_iff : a ≤ infi s ↔ (∀i, a ≤ s i) :=
⟨assume : a ≤ infi s, assume i, le_trans this (infi_le _ _), le_infi⟩

@[congr] theorem infi_congr_Prop {p q : Prop} {f₁ : p → α} {f₂ : q → α}
  (pq : p ↔ q) (f : ∀x, f₁ (pq.mpr x) = f₂ x) : infi f₁ = infi f₂ :=
le_antisymm
  (infi_le_infi2 $ assume j, ⟨pq.mpr j, le_of_eq $ f j⟩)
  (infi_le_infi2 $ assume j, ⟨pq.mp j, le_of_eq $ (f _).symm⟩)

@[simp] theorem infi_const {a : α} [inhabited ι] : (⨅ b:ι, a) = a :=
le_antisymm (Inf_le ⟨arbitrary ι, rfl⟩) (by finish)

@[simp] theorem supr_const {a : α} [inhabited ι] : (⨆ b:ι, a) = a :=
le_antisymm (by finish) (le_Sup ⟨arbitrary ι, rfl⟩)

-- TODO: should this be @[simp]?
theorem infi_comm {f : ι → ι₂ → α} : (⨅i, ⨅j, f i j) = (⨅j, ⨅i, f i j) :=
le_antisymm
  (le_infi $ assume i, le_infi $ assume j, infi_le_of_le j $ infi_le _ i)
  (le_infi $ assume j, le_infi $ assume i, infi_le_of_le i $ infi_le _ j)

/- TODO: this is strange. In the proof below, we get exactly the desired
   among the equalities, but close does not get it.
begin
  apply @le_antisymm,
    simp, intros,
    begin [smt]
      ematch, ematch, ematch, trace_state, have := le_refl (f i_1 i),
      trace_state, close
    end
end
-/

-- TODO: should this be @[simp]?
theorem supr_comm {f : ι → ι₂ → α} : (⨆i, ⨆j, f i j) = (⨆j, ⨆i, f i j) :=
le_antisymm
  (supr_le $ assume i, supr_le $ assume j, le_supr_of_le j $ le_supr _ i)
  (supr_le $ assume j, supr_le $ assume i, le_supr_of_le i $ le_supr _ j)

@[simp] theorem infi_infi_eq_left {b : β} {f : Πx:β, x = b → α} : (⨅x, ⨅h:x = b, f x h) = f b rfl :=
le_antisymm
  (infi_le_of_le b $ infi_le _ rfl)
  (le_infi $ assume b', le_infi $ assume eq, match b', eq with ._, rfl := le_refl _ end)

@[simp] theorem infi_infi_eq_right {b : β} {f : Πx:β, b = x → α} : (⨅x, ⨅h:b = x, f x h) = f b rfl :=
le_antisymm
  (infi_le_of_le b $ infi_le _ rfl)
  (le_infi $ assume b', le_infi $ assume eq, match b', eq with ._, rfl := le_refl _ end)

@[simp] theorem supr_supr_eq_left {b : β} {f : Πx:β, x = b → α} : (⨆x, ⨆h : x = b, f x h) = f b rfl :=
le_antisymm
  (supr_le $ assume b', supr_le $ assume eq, match b', eq with ._, rfl := le_refl _ end)
  (le_supr_of_le b $ le_supr _ rfl)

@[simp] theorem supr_supr_eq_right {b : β} {f : Πx:β, b = x → α} : (⨆x, ⨆h : b = x, f x h) = f b rfl :=
le_antisymm
  (supr_le $ assume b', supr_le $ assume eq, match b', eq with ._, rfl := le_refl _ end)
  (le_supr_of_le b $ le_supr _ rfl)

attribute [ematch] le_refl

@[ematch] theorem foo {a b : α} (h : a = b) : a ≤ b :=
by rw h; apply le_refl

@[ematch] theorem foo' {a b : α} (h : b = a) : a ≤ b :=
by rw h; apply le_refl

theorem infi_inf_eq {f g : β → α} : (⨅ x, f x ⊓ g x) = (⨅ x, f x) ⊓ (⨅ x, g x) :=
le_antisymm
  (le_inf
    (le_infi $ assume i, infi_le_of_le i inf_le_left)
    (le_infi $ assume i, infi_le_of_le i inf_le_right))
  (le_infi $ assume i, le_inf
    (inf_le_left_of_le $ infi_le _ _)
    (inf_le_right_of_le $ infi_le _ _))

/- TODO: here is another example where more flexible pattern matching
   might help.

begin
  apply @le_antisymm,
  safe, pose h := f a ⊓ g a, begin [smt] ematch, ematch  end
end
-/

theorem supr_sup_eq {f g : β → α} : (⨆ x, f x ⊔ g x) = (⨆ x, f x) ⊔ (⨆ x, g x) :=
le_antisymm
  (supr_le $ assume i, sup_le
    (le_sup_left_of_le $ le_supr _ _)
    (le_sup_right_of_le $ le_supr _ _))
  (sup_le
    (supr_le $ assume i, le_supr_of_le i le_sup_left)
    (supr_le $ assume i, le_supr_of_le i le_sup_right))

/- supr and infi under Prop -/

@[simp] theorem infi_false {s : false → α} : infi s = ⊤ :=
le_antisymm le_top (le_infi $ assume i, false.elim i)

@[simp] theorem supr_false {s : false → α} : supr s = ⊥ :=
le_antisymm (supr_le $ assume i, false.elim i) bot_le

@[simp] theorem infi_true {s : true → α} : infi s = s trivial :=
le_antisymm (infi_le _ _) (le_infi $ assume ⟨⟩, le_refl _)

@[simp] theorem supr_true {s : true → α} : supr s = s trivial :=
le_antisymm (supr_le $ assume ⟨⟩, le_refl _) (le_supr _ _)

@[simp] theorem infi_exists {p : ι → Prop} {f : Exists p → α} : (⨅ x, f x) = (⨅ i, ⨅ h:p i, f ⟨i, h⟩) :=
le_antisymm
  (le_infi $ assume i, le_infi $ assume : p i, infi_le _ _)
  (le_infi $ assume ⟨i, h⟩, infi_le_of_le i $ infi_le _ _)

@[simp] theorem supr_exists {p : ι → Prop} {f : Exists p → α} : (⨆ x, f x) = (⨆ i, ⨆ h:p i, f ⟨i, h⟩) :=
le_antisymm
  (supr_le $ assume ⟨i, h⟩, le_supr_of_le i $ le_supr (λh:p i, f ⟨i, h⟩) _)
  (supr_le $ assume i, supr_le $ assume : p i, le_supr _ _)

theorem infi_and {p q : Prop} {s : p ∧ q → α} : infi s = (⨅ h₁ : p, ⨅ h₂ : q, s ⟨h₁, h₂⟩) :=
le_antisymm
  (le_infi $ assume i, le_infi $ assume j, infi_le _ _)
  (le_infi $ assume ⟨i, h⟩, infi_le_of_le i $ infi_le _ _)

theorem supr_and {p q : Prop} {s : p ∧ q → α} : supr s = (⨆ h₁ : p, ⨆ h₂ : q, s ⟨h₁, h₂⟩) :=
le_antisymm
  (supr_le $ assume ⟨i, h⟩, le_supr_of_le i $ le_supr (λj, s ⟨i, j⟩) _)
  (supr_le $ assume i, supr_le $ assume j, le_supr _ _)

theorem infi_or {p q : Prop} {s : p ∨ q → α} :
  infi s = (⨅ h : p, s (or.inl h)) ⊓ (⨅ h : q, s (or.inr h)) :=
le_antisymm
  (le_inf
    (infi_le_infi2 $ assume j, ⟨_, le_refl _⟩)
    (infi_le_infi2 $ assume j, ⟨_, le_refl _⟩))
  (le_infi $ assume i, match i with
  | or.inl i := inf_le_left_of_le $ infi_le _ _
  | or.inr j := inf_le_right_of_le $ infi_le _ _
  end)

theorem supr_or {p q : Prop} {s : p ∨ q → α} :
  (⨆ x, s x) = (⨆ i, s (or.inl i)) ⊔ (⨆ j, s (or.inr j)) :=
le_antisymm
  (supr_le $ assume s, match s with
  | or.inl i := le_sup_left_of_le $ le_supr _ i
  | or.inr j := le_sup_right_of_le $ le_supr _ j
  end)
  (sup_le
    (supr_le_supr2 $ assume i, ⟨or.inl i, le_refl _⟩)
    (supr_le_supr2 $ assume j, ⟨or.inr j, le_refl _⟩))

theorem Inf_eq_infi {s : set α} : Inf s = (⨅a ∈ s, a) :=
le_antisymm
  (le_infi $ assume b, le_infi $ assume h, Inf_le h)
  (le_Inf $ assume b h, infi_le_of_le b $ infi_le _ h)

theorem Sup_eq_supr {s : set α} : Sup s = (⨆a ∈ s, a) :=
le_antisymm
  (Sup_le $ assume b h, le_supr_of_le b $ le_supr _ h)
  (supr_le $ assume b, supr_le $ assume h, le_Sup h)

lemma Sup_range {f : ι → α} : Sup (range f) = supr f :=
le_antisymm
  (Sup_le $ forall_range_iff.mpr $ assume i, le_supr _ _)
  (supr_le $ assume i, le_Sup mem_range)

lemma Inf_range {f : ι → α} : Inf (range f) = infi f :=
le_antisymm
  (le_infi $ assume i, Inf_le mem_range)
  (le_Inf $ forall_range_iff.mpr $ assume i, infi_le _ _)

lemma supr_range {g : β → α} {f : ι → β} : (⨆b∈range f, g b) = (⨆i, g (f i)) :=
le_antisymm
  (supr_le $ assume b, supr_le $ assume ⟨i, (h : f i = b)⟩, h ▸ le_supr _ i)
  (supr_le $ assume i, le_supr_of_le (f i) $ le_supr (λp, g (f i)) mem_range)

lemma infi_range {g : β → α} {f : ι → β} : (⨅b∈range f, g b) = (⨅i, g (f i)) :=
le_antisymm
  (le_infi $ assume i, infi_le_of_le (f i) $ infi_le (λp, g (f i)) mem_range)
  (le_infi $ assume b, le_infi $ assume ⟨i, (h : f i = b)⟩, h ▸ infi_le _ i)

theorem Inf_image {s : set β} {f : β → α} : Inf (f '' s) = (⨅ a ∈ s, f a) :=
calc Inf (set.image f s) = (⨅a, ⨅h : ∃b, b ∈ s ∧ f b = a, a) : Inf_eq_infi
                     ... = (⨅a, ⨅b, ⨅h : f b = a ∧ b ∈ s, a) : by simp
                     ... = (⨅a, ⨅b, ⨅h : a = f b, ⨅h : b ∈ s, a) : by simp [infi_and, eq_comm]
                     ... = (⨅b, ⨅a, ⨅h : a = f b, ⨅h : b ∈ s, a) : by rw [infi_comm]
                     ... = (⨅a∈s, f a) : congr_arg infi $ funext $ assume x, by rw [infi_infi_eq_left]

theorem Sup_image {s : set β} {f : β → α} : Sup (f '' s) = (⨆ a ∈ s, f a) :=
calc Sup (set.image f s) = (⨆a, ⨆h : ∃b, b ∈ s ∧ f b = a, a) : Sup_eq_supr
                     ... = (⨆a, ⨆b, ⨆h : f b = a ∧ b ∈ s, a) : by simp
                     ... = (⨆a, ⨆b, ⨆h : a = f b, ⨆h : b ∈ s, a) : by simp [supr_and, eq_comm]
                     ... = (⨆b, ⨆a, ⨆h : a = f b, ⨆h : b ∈ s, a) : by rw [supr_comm]
                     ... = (⨆a∈s, f a) : congr_arg supr $ funext $ assume x, by rw [supr_supr_eq_left]

/- supr and infi under set constructions -/

/- should work using the simplifier! -/
@[simp] theorem infi_emptyset {f : β → α} : (⨅ x ∈ (∅ : set β), f x) = ⊤ :=
le_antisymm le_top (le_infi $ assume x, le_infi false.elim)

@[simp] theorem supr_emptyset {f : β → α} : (⨆ x ∈ (∅ : set β), f x) = ⊥ :=
le_antisymm (supr_le $ assume x, supr_le false.elim) bot_le

@[simp] theorem infi_univ {f : β → α} : (⨅ x ∈ (univ : set β), f x) = (⨅ x, f x) :=
show (⨅ (x : β) (H : true), f x) = ⨅ (x : β), f x,
  from congr_arg infi $ funext $ assume x, infi_const

@[simp] theorem supr_univ {f : β → α} : (⨆ x ∈ (univ : set β), f x) = (⨆ x, f x) :=
show (⨆ (x : β) (H : true), f x) = ⨆ (x : β), f x,
  from congr_arg supr $ funext $ assume x, supr_const

@[simp] theorem infi_union {f : β → α} {s t : set β} : (⨅ x ∈ s ∪ t, f x) = (⨅x∈s, f x) ⊓ (⨅x∈t, f x) :=
calc (⨅ x ∈ s ∪ t, f x) = (⨅ x, (⨅h : x∈s, f x) ⊓ (⨅h : x∈t, f x)) : congr_arg infi $ funext $ assume x, infi_or
                    ... = (⨅x∈s, f x) ⊓ (⨅x∈t, f x) : infi_inf_eq

@[simp] theorem supr_union {f : β → α} {s t : set β} : (⨆ x ∈ s ∪ t, f x) = (⨆x∈s, f x) ⊔ (⨆x∈t, f x) :=
calc (⨆ x ∈ s ∪ t, f x) = (⨆ x, (⨆h : x∈s, f x) ⊔ (⨆h : x∈t, f x)) : congr_arg supr $ funext $ assume x, supr_or
                    ... = (⨆x∈s, f x) ⊔ (⨆x∈t, f x) : supr_sup_eq

@[simp] theorem insert_of_has_insert (x : α) (a : set α) : has_insert.insert x a = insert x a := rfl

@[simp] theorem infi_insert {f : β → α} {s : set β} {b : β} : (⨅ x ∈ insert b s, f x) = f b ⊓ (⨅x∈s, f x) :=
eq.trans infi_union $ congr_arg (λx:α, x ⊓ (⨅x∈s, f x)) infi_infi_eq_left

@[simp] theorem supr_insert {f : β → α} {s : set β} {b : β} : (⨆ x ∈ insert b s, f x) = f b ⊔ (⨆x∈s, f x) :=
eq.trans supr_union $ congr_arg (λx:α, x ⊔ (⨆x∈s, f x)) supr_supr_eq_left

@[simp] theorem infi_singleton {f : β → α} {b : β} : (⨅ x ∈ (singleton b : set β), f x) = f b :=
show (⨅ x ∈ insert b (∅ : set β), f x) = f b,
  by simp

@[simp] theorem supr_singleton {f : β → α} {b : β} : (⨆ x ∈ (singleton b : set β), f x) = f b :=
show (⨆ x ∈ insert b (∅ : set β), f x) = f b,
  by simp

/- supr and infi under Type -/

@[simp] theorem infi_empty {s : empty → α} : infi s = ⊤ :=
le_antisymm le_top (le_infi $ assume i, empty.rec_on _ i)

@[simp] theorem supr_empty {s : empty → α} : supr s = ⊥ :=
le_antisymm (supr_le $ assume i, empty.rec_on _ i) bot_le

@[simp] theorem infi_unit {f : unit → α} : (⨅ x, f x) = f () :=
le_antisymm (infi_le _ _) (le_infi $ assume ⟨⟩, le_refl _)

@[simp] theorem supr_unit {f : unit → α} : (⨆ x, f x) = f () :=
le_antisymm (supr_le $ assume ⟨⟩, le_refl _) (le_supr _ _)

theorem infi_subtype {p : ι → Prop} {f : subtype p → α} : (⨅ x, f x) = (⨅ i, ⨅ h:p i, f ⟨i, h⟩) :=
le_antisymm
  (le_infi $ assume i, le_infi $ assume : p i, infi_le _ _)
  (le_infi $ assume ⟨i, h⟩, infi_le_of_le i $ infi_le _ _)

theorem supr_subtype {p : ι → Prop} {f : subtype p → α} : (⨆ x, f x) = (⨆ i, ⨆ h:p i, f ⟨i, h⟩) :=
le_antisymm
  (supr_le $ assume ⟨i, h⟩, le_supr_of_le i $ le_supr (λh:p i, f ⟨i, h⟩) _)
  (supr_le $ assume i, supr_le $ assume : p i, le_supr _ _)

theorem infi_sigma {p : β → Type w} {f : sigma p → α} : (⨅ x, f x) = (⨅ i, ⨅ h:p i, f ⟨i, h⟩) :=
le_antisymm
  (le_infi $ assume i, le_infi $ assume : p i, infi_le _ _)
  (le_infi $ assume ⟨i, h⟩, infi_le_of_le i $ infi_le _ _)

theorem supr_sigma {p : β → Type w} {f : sigma p → α} : (⨆ x, f x) = (⨆ i, ⨆ h:p i, f ⟨i, h⟩) :=
le_antisymm
  (supr_le $ assume ⟨i, h⟩, le_supr_of_le i $ le_supr (λh:p i, f ⟨i, h⟩) _)
  (supr_le $ assume i, supr_le $ assume : p i, le_supr _ _)

theorem infi_prod {γ : Type w} {f : β × γ → α} : (⨅ x, f x) = (⨅ i, ⨅ j, f (i, j)) :=
le_antisymm
  (le_infi $ assume i, le_infi $ assume j, infi_le _ _)
  (le_infi $ assume ⟨i, h⟩, infi_le_of_le i $ infi_le _ _)

theorem supr_prod {γ : Type w} {f : β × γ → α} : (⨆ x, f x) = (⨆ i, ⨆ j, f (i, j)) :=
le_antisymm
  (supr_le $ assume ⟨i, h⟩, le_supr_of_le i $ le_supr (λj, f ⟨i, j⟩) _)
  (supr_le $ assume i, supr_le $ assume j, le_supr _ _)

theorem infi_sum {γ : Type w} {f : β ⊕ γ → α} :
  (⨅ x, f x) = (⨅ i, f (sum.inl i)) ⊓ (⨅ j, f (sum.inr j)) :=
le_antisymm
  (le_inf
    (infi_le_infi2 $ assume i, ⟨_, le_refl _⟩)
    (infi_le_infi2 $ assume j, ⟨_, le_refl _⟩))
  (le_infi $ assume s, match s with
  | sum.inl i := inf_le_left_of_le $ infi_le _ _
  | sum.inr j := inf_le_right_of_le $ infi_le _ _
  end)

theorem supr_sum {γ : Type w} {f : β ⊕ γ → α} :
  (⨆ x, f x) = (⨆ i, f (sum.inl i)) ⊔ (⨆ j, f (sum.inr j)) :=
le_antisymm
  (supr_le $ assume s, match s with
  | sum.inl i := le_sup_left_of_le $ le_supr _ i
  | sum.inr j := le_sup_right_of_le $ le_supr _ j
  end)
  (sup_le
    (supr_le_supr2 $ assume i, ⟨sum.inl i, le_refl _⟩)
    (supr_le_supr2 $ assume j, ⟨sum.inr j, le_refl _⟩))

end

/- Instances -/

instance complete_lattice_Prop : complete_lattice Prop :=
{ lattice.bounded_lattice_Prop with
  Sup    := λs, ∃a∈s, a,
  le_Sup := assume s a h p, ⟨a, h, p⟩,
  Sup_le := assume s a h ⟨b, h', p⟩, h b h' p,
  Inf    := λs, ∀a:Prop, a∈s → a,
  Inf_le := assume s a h p, p a h,
  le_Inf := assume s a h p b hb, h b hb p }

instance complete_lattice_fun {α : Type u} {β : Type v} [complete_lattice β] :
  complete_lattice (α → β) :=
{ lattice.bounded_lattice_fun with
  Sup    := λs a, Sup (set.image (λf : α → β, f a) s),
  le_Sup := assume s f h a, le_Sup ⟨f, h, rfl⟩,
  Sup_le := assume s f h a, Sup_le $ assume b ⟨f', h', b_eq⟩, b_eq ▸ h _ h' a,
  Inf    := λs a, Inf (set.image (λf : α → β, f a) s),
  Inf_le := assume s f h a, Inf_le ⟨f, h, rfl⟩,
  le_Inf := assume s f h a, le_Inf $ assume b ⟨f', h', b_eq⟩, b_eq ▸ h _ h' a }

section complete_lattice
variables [preorder α] [complete_lattice β]

theorem monotone_Sup_of_monotone {s : set (α → β)} (m_s : ∀f∈s, monotone f) : monotone (Sup s) :=
assume x y h, Sup_le $ assume x' ⟨f, f_in, fx_eq⟩, le_Sup_of_le ⟨f, f_in, rfl⟩ $ fx_eq ▸ m_s _ f_in h

theorem monotone_Inf_of_monotone {s : set (α → β)} (m_s : ∀f∈s, monotone f) : monotone (Inf s) :=
assume x y h, le_Inf $ assume x' ⟨f, f_in, fx_eq⟩, Inf_le_of_le ⟨f, f_in, rfl⟩ $ fx_eq ▸ m_s _ f_in h

end complete_lattice

end lattice

section ord_continuous
open lattice
variables [complete_lattice α] [complete_lattice β]

def ord_continuous (f : α → β) := ∀s : set α, f (Sup s) = (⨆i∈s, f i)

lemma ord_continuous_sup {f : α → β} {a₁ a₂ : α} (hf : ord_continuous f) : f (a₁ ⊔ a₂) = f a₁ ⊔ f a₂ :=
have h : f (Sup {a₁, a₂}) = (⨆i∈({a₁, a₂} : set α), f i), from hf _,
have h₁ : {a₁, a₂} = (insert a₂ {a₁} : set α), from rfl,
begin
  rw [h₁, Sup_insert, Sup_singleton, sup_comm] at h,
  rw [h, supr_insert, supr_singleton, sup_comm]
end

lemma ord_continuous_mono {f : α → β} (hf : ord_continuous f) : monotone f :=
assume a₁ a₂ h,
calc f a₁ ≤ f a₁ ⊔ f a₂ : le_sup_left
  ... = f (a₁ ⊔ a₂) : (ord_continuous_sup hf).symm
  ... = _ : by rw [sup_of_le_right h]

end ord_continuous

/- Classical statements:

@[simp] theorem Inf_eq_top : Inf s = ⊤ ↔ (∀a∈s, a = ⊤) :=
_

@[simp] theorem infi_eq_top : infi s = ⊤ ↔ (∀i, s i = ⊤) :=
_

@[simp] theorem Sup_eq_bot : Sup s = ⊤ ↔ (∀a∈s, a = ⊥) :=
_

@[simp] theorem supr_eq_top : supr s = ⊤ ↔ (∀i, s i = ⊥) :=
_


-/
