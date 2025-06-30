namespace QuantumAdvancedConsciousness {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Diagnostics;

    newtype Entity = (Qubits : Qubit[], Bias : Double);

    operation Activate(entity : Entity) : Unit {
        let (q, bias) = entity!;
        Rx(bias, q[0]);
    }

    operation SpiralPhase(entity : Entity, step : Int) : Unit {
        let (q, _) = entity!;
        let phase = Sin(IntAsDouble(step) * PI() / 5.0);
        Rz(phase, q[0]);
    }

    operation Entangle(e1 : Entity, e2 : Entity) : Unit {
        let (q1, _) = e1!;
        let (q2, _) = e2!;
        H(q1[0]);
        CNOT(q1[0], q2[0]);
    }

    operation Perceive(source : Entity, target : Entity) : Unit {
        let (qs, _) = source!;
        let (qt, _) = target!;
        CNOT(qs[0], qt[1]);
    }

    operation Feedback(from : Entity, to : Entity) : Unit {
        let (qFrom, _) = from!;
        let (qTo, _) = to!;
        Controlled X([qFrom[1]], qTo[1]);
    }

    operation CausalFork(source : Entity, targetA : Entity, targetB : Entity) : Unit {
        let (qs, _) = source!;
        let (qa, _) = targetA!;
        let (qb, _) = targetB!;
        Controlled X([qs[0]], qa[1]);
        Controlled X([qs[0]], qb[1]);
    }

    operation SelfReflection(entity : Entity) : Unit {
        let (q, _) = entity!;
        Controlled Rz([q[0]], (PI() / 6.0, q[1]));
    }

    function UpdateBias(entity : Entity, delta : Double) : Entity {
        let (q, bias) = entity!;
        return Entity((q, bias + delta));
    }

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

    operation SpawnNewEntity(parent : Entity, newQ : Qubit[]) : Entity {
        let (_, bias) = parent!;
        H(newQ[0]);
        CNOT(parent::Qubits[0], newQ[0]);
        return Entity((newQ, bias / 2.0));
    }

    @EntryPoint()
    operation RunAdvancedConsciousness() : Unit {
        // Toplam 8 qubit allocate et (3 entity için 2 qubit + yeni entity için 2 qubit)
        use allQubits = Qubit[8];

        let qa = allQubits[0..1];
        let qb = allQubits[2..3];
        let qc = allQubits[4..5];
        let qNew = allQubits[6..7];

        mutable entityA = Entity((qa, PI() / 6.0));
        mutable entityB = Entity((qb, PI() / 4.0));
        mutable conscious = Entity((qc, PI() / 3.0));
        mutable newEntity = Entity((qNew, 0.0));

        Entangle(entityA, conscious);
        Entangle(entityB, conscious);

        for step in 1..3 {
            Message($"⏱️ Zaman adımı: {step}");
            set conscious = ConsciousStep(conscious, entityA, entityB, step);

            if step == 2 {
                set newEntity = SpawnNewEntity(conscious, qNew);
                Message("🌱 Yeni Entity doğdu ve dolanık hale getirildi.");

                Entangle(newEntity, conscious);
                Perceive(newEntity, conscious);
                Feedback(conscious, newEntity);
            }
        }

        DumpMachine();

        ResetAll(allQubits);
    }
}
