Parameters A,B,C,D: bool
we need to prove A⇒(A⇒B)⇒(A⇒C)⇒(B⇒C⇒D)⇒D
  assume A (a)
  assume A⇒B (ab)
  assume A⇒C (ac)
  assume B⇒C⇒D (bcd)
  we need to prove D
    by bcd
    and we need to prove B
      by ab
      and by a
    done
    and we need to prove C
      by ac
      and by a
    done
  done
done
we need to prove A⇒(A⇒B)⇒(A⇒C)⇒(B⇒C⇒D)⇒D
  assume A (a)
  assume A⇒B (ab)
  assume A⇒C (ac)
  assume B⇒C⇒D (bcd)
  we need to prove D
    by a
    we proved A (a2)
    by ab
    and by a2
    we proved B (b)
    by ac
    and by a2
    we proved C (c)
    by bcd
    and by b
    and by c
  done
done