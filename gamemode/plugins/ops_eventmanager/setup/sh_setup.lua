mrp.Ops = mrp.Ops or {}
mrp.Ops.EventManager = mrp.Ops.EventManager or {}
mrp.Ops.EventManager.Sequences = mrp.Ops.EventManager.Sequences or {}
mrp.Ops.EventManager.Scenes = mrp.Ops.EventManager.Scenes or {}
mrp.Ops.EventManager.Data = mrp.Ops.EventManager.Data or {}
mrp.Ops.EventManager.Config = mrp.Ops.EventManager.Config or {}

file.CreateDir("mrp/ops/eventmanager")

hook.Run("OpsSetup")