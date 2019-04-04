Partial Reconfiguration
=======================

1.  Synthesize the static and Reconfigurable Modules separately.
2.  Create physical constraints (Pblocks) to define the reconfigurable regions.
3.  Set the HD.RECONFIGURABLE property on each Reconfigurable Partition.
4.  Implement a complete design (static and one Reconfigurable Module per Reconfigurable Partition) in context.
5.  Save a design checkpoint for the full routed design.
6.  Remove Reconfigurable Modules from this design and save a static-only design checkpoint. 
7.  Lock the static placement and routing.
8.  Add new Reconfigurable Modules to the static design and implement this new configuration, saving a checkpoint for the full routed design.
9.  Repeat Step 8 until all Reconfigurable Modules are implemented.
10. Run a verification utility (pr_verify) on all configurations.
11. Create bitstreams for each configuration