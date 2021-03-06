class Coq < Formula
  desc "Proof assistant for higher-order logic"
  homepage "https://coq.inria.fr/"
  url "https://github.com/coq/coq/archive/V8.10.1.tar.gz"
  sha256 "f8eb889c4974b89db1303b22382b2de4116ede1db673afefc67e3abff8955612"
  head "https://github.com/coq/coq.git"

  bottle do
    sha256 "ad44a6694028e971ebe8b203dc5b240353133482d0766666bbaacee8bc2b6b1d" => :catalina
    sha256 "26ee42e17513ae2e7d5a3fa4ee7185fd2e1c3b3d60eb61ba5b499871542cf715" => :mojave
    sha256 "4bea2021c232045a6535a33f18f05b1e36533920df3c8245cbfb52d42279c69f" => :high_sierra
    sha256 "5c901abba048e4b76f066b114b1db4df461f2c72893acf2f8e08ba4ecc81c055" => :x86_64_linux
  end

  depends_on "ocaml-findlib" => :build
  depends_on "camlp5"
  depends_on "ocaml"
  depends_on "ocaml-num"

  unless OS.mac?
    depends_on "unzip" => :build
    depends_on "m4"
  end

  def install
    system "./configure", "-prefix", prefix,
                          "-mandir", man,
                          "-coqdocdir", "#{pkgshare}/latex",
                          "-coqide", "no",
                          "-with-doc", "no"
    system "make", "world"
    ENV.deparallelize { system "make", "install" }
  end

  test do
    (testpath/"testing.v").write <<~EOS
      Require Coq.omega.Omega.
      Require Coq.ZArith.ZArith.

      Inductive nat : Set :=
      | O : nat
      | S : nat -> nat.
      Fixpoint add (n m: nat) : nat :=
        match n with
        | O => m
        | S n' => S (add n' m)
        end.
      Lemma add_O_r : forall (n: nat), add n O = n.
      Proof.
      intros n; induction n; simpl; auto; rewrite IHn; auto.
      Qed.

      Import Coq.omega.Omega.
      Import Coq.ZArith.ZArith.
      Open Scope Z.
      Lemma add_O_r_Z : forall (n: Z), n + 0 = n.
      Proof.
      intros; omega.
      Qed.
    EOS
    system("#{bin}/coqc", "#{testpath}/testing.v")
  end
end
