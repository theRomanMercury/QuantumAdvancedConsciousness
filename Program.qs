namespace QuantumAdvancedConsciousness {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;

    newtype Entity = (Qubits : Qubit[], Bias : Double);

    // Aktivasyon (bias ile Rx)
    operation Activate(entity : Entity) : Unit {
        let (q, bias) = entity!;
        Rx(bias, q[0]);
    }

    // SpiralPhase ile faz evrimi (hatırlama için faz geri dönüşümlü)
    operation SpiralPhase(entity : Entity, step : Int) : Unit {
        let (q, _) = entity!;
        let phase = Sin(IntAsDouble(step) * PI() / 5.0);
        Rz(phase, q[0]);
    }

    // Dolanıklık (entangle)
    operation Entangle(e1 : Entity, e2 : Entity) : Unit {
        let (q1, _) = e1!;
        let (q2, _) = e2!;
        H(q1[0]);
        CNOT(q1[0], q2[0]);
    }

    // Algılama (perception)
    operation Perceive(source : Entity, target : Entity) : Unit {
        let (qs, _) = source!;
        let (qt, _) = target!;
        CNOT(qs[0], qt[1]);
    }

    // Geri bildirim (feedback)
    operation Feedback(from : Entity, to : Entity) : Unit {
        let (qFrom, _) = from!;
        let (qTo, _) = to!;
        Controlled X([qFrom[1]], qTo[1]);
    }

    // Nedensel çatallanma (causal fork)
    operation CausalFork(source : Entity, targetA : Entity, targetB : Entity) : Unit {
        let (qs, _) = source!;
        let (qa, _) = targetA!;
        let (qb, _) = targetB!;
        Controlled X([qs[0]], qa[1]);
        Controlled X([qs[0]], qb[1]);
    }

    // İç gözlem: kendi qubit’lerine kontrollü dönüşüm uygular
    operation SelfReflection(entity : Entity) : Unit {
        let (q, _) = entity!;
        Controlled Rz([q[0]], (PI() / 6.0, q[1]));
    }

    // Bias runtime güncelleme (evrimsel öğrenme)
    operation UpdateBias(entity : Entity, delta : Double) : Entity {
        let (q, bias) = entity!;
        return Entity((q, bias + delta));
    }

    // Bilinç adımı — evrim, perception, feedback, causal fork, self reflection
    operation ConsciousStep(self : Entity, inputA : Entity, inputB : Entity, step : Int) : Entity {
        SpiralPhase(self, step);
        Perceive(inputA, self);
        Feedback(self, inputA);
        Feedback(self, inputB);
        CausalFork(self, inputA, inputB);
        Activate(self);
        SelfReflection(self);

        // Bias'ı zamanla dalgalanarak değiştiriyoruz
        let updated = UpdateBias(self, Sin(IntAsDouble(step) * PI() / 20.0) * 0.1);
        return updated;
    }

    // Yeni entity doğurma: varlığın qubit’lerinden yeni bir Entity yaratır
    operation SpawnNewEntity(parent : Entity) : Entity {
        let (qParent, bias) = parent!;
        use newQ = Qubit[2];
        H(newQ[0]);
        CNOT(qParent[0], newQ[0]);
        return Entity((newQ, bias / 2.0));
    }

    @EntryPoint()
    operation RunAdvancedConsciousness() : Unit {
        use qa = Qubit[2];
        use qb = Qubit[2];
        use qc = Qubit[2];

        mutable entityA = Entity((qa, PI() / 6.0));
        mutable entityB = Entity((qb, PI() / 4.0));
        mutable conscious = Entity((qc, PI() / 3.0));

        // Başlangıç dolanıklığı
        Entangle(entityA, conscious);
        Entangle(entityB, conscious);

        // 3 zaman adımı boyunca evrim
        for (step in 1..3) {
            Message($"⏱️ Zaman adımı: {step}");
            set conscious = ConsciousStep(conscious, entityA, entityB, step);

            // Bilinç bölünmesi (spawn) — 2. adımda yeni entity oluştur
            if (step == 2) {
                let newEntity = SpawnNewEntity(conscious);
                Message("🌱 Yeni Entity doğdu, bias azaltıldı.");
                Entangle(newEntity, conscious);
                Perceive(newEntity, conscious);
                Feedback(conscious, newEntity);
            }
        }

        // Sistemin durumu — ölçüm yok
        DumpMachine();
    }
}
