namespace QuantumAdvancedConsciousness {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    newtype Entity = (Qubits : Qubit[], Bias : Double);

    // Aktivasyon: bias ile Rx uygulaması
    operation Activate(entity : Entity) : Unit {
        let (q, bias) = entity!;
        Rx(bias, q[0]);
    }

    // Spiral faz evrimi (zamana bağlı Rz)
    operation SpiralPhase(entity : Entity, step : Int) : Unit {
        let (q, _) = entity!;
        let phase = Sin(IntAsDouble(step) * PI() / 5.0);
        Rz(phase, q[0]);
    }

    // Dolanıklık (entanglement)
    operation Entangle(e1 : Entity, e2 : Entity) : Unit {
        let (q1, _) = e1!;
        let (q2, _) = e2!;
        H(q1[0]);
        CNOT(q1[0], q2[0]);
    }

    // Algılama (perceive)
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

    // İç gözlem (self-reflection)
    operation SelfReflection(entity : Entity) : Unit {
        let (q, _) = entity!;
        Controlled Rz([q[0]], (PI() / 6.0, q[1]));
    }

    // Bias güncelleme (saf klasik)
    function UpdateBias(entity : Entity, delta : Double) : Entity {
        let (q, bias) = entity!;
        return Entity((q, bias + delta));
    }

    // Bilinç evrimi adımı
    operation ConsciousStep(selfEntity : Entity, inputA : Entity, inputB : Entity, step : Int) : Entity {
        SpiralPhase(selfEntity, step);
        Perceive(inputA, selfEntity);
        Feedback(selfEntity, inputA);
        Feedback(selfEntity, inputB);
        CausalFork(selfEntity, inputA, inputB);
        Activate(selfEntity);
        SelfReflection(selfEntity);

        let updated = UpdateBias(selfEntity, Sin(IntAsDouble(step) * PI() / 20.0) * 0.1);
        return updated;
    }

    // Yeni bir entity oluştur (qubit dışarıdan verilir)
    operation SpawnNewEntity(parent : Entity, newQ : Qubit[]) : Entity {
        let (qParent, bias) = parent!;
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

        // Başlangıçta dolanıklık
        Entangle(entityA, conscious);
        Entangle(entityB, conscious);

        for step in 1..3 {
            Message($"⏱️ Zaman adımı: {step}");
            set conscious = ConsciousStep(conscious, entityA, entityB, step);

            // 2. adımda yeni bir entity doğur
            if step == 2 {
                use newQ = Qubit[2];
                let newEntity = SpawnNewEntity(conscious, newQ);
                Message("🌱 Yeni Entity doğdu ve dolanık hale getirildi.");
                Entangle(newEntity, conscious);
                Perceive(newEntity, conscious);
                Feedback(conscious, newEntity);

                // Reset newQ qubits explicitly before leaving this scope
                ResetAll(newQ);
            }
        }

        // Reset original qubits before release
        ResetAll(qa);
        ResetAll(qb);
        ResetAll(qc);

        // Durumu görüntüle (ölçüm yok, çökme yok)
        DumpMachine();
    }
}
