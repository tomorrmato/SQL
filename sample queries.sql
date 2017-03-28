
-- Query 1

with T1 as
	(select EmpProject.ProjId, EmpProject.EmpId, University.UnivId
	from EmpProject, Graduate, University
	where EmpProject.EmpId = Graduate.EmpId and Graduate.UnivId = University.UnivId
		),
	T2 as 
	(select EmpProject.ProjId, EmpProject.EmpId, University.UnivId
	from EmpProject, Graduate, University
	where EmpProject.EmpId = Graduate.EmpId and Graduate.UnivId = University.UnivId
		)
select Project.ProjName
from Project
where Project.ProjId NOT in(
	select distinct(T1.ProjId)
	from T1, T2
	where T1.EmpId <> T2.EmpId and T1.UnivId <> T2.UnivId and T1.ProjId = T2.ProjId 
);

-- Query 2

with R1 as
	(select University.UnivName, ProjectManager.MgrId
	from  University, Graduate, EmpProject, ProjectManager
	where University.UnivId = Graduate.UnivId and Graduate.EmpId = EmpProject.EmpId and EmpProject.ProjId = ProjectManager.ProjId
		),
	R2 as
	(select R1.UnivName, count(distinct(R1.MgrId)) as dis_mgr_count
	from R1
	group by R1.UnivName
		),
	R3 as
	(select R1.UnivName, count(distinct(R1.MgrId)) as dis_mgr_count
	from R1
	group by R1.UnivName
		)
select distinct(R2.UnivName)
from R2, R3
where R2.dis_mgr_count = (select max(R3.dis_mgr_count) from R3);

-- Query 3

with T1 as
	(select PM1.ProjId, PM1.MgrId, sum(CASE 
            WHEN PM1.EndDate is null  
               THEN CURRENT_DATE-PM1.StartDate
               ELSE PM1.EndDate-PM1.StartDate
       		END) duration
	from ProjectManager PM1
	group by PM1.ProjId, PM1.MgrId
		),
	T2 as 
	(select PM2.ProjId, PM2.MgrId, sum(CASE 
            WHEN PM2.EndDate is null  
               THEN CURRENT_DATE-PM2.StartDate
               ELSE PM2.EndDate-PM2.StartDate
       		END) duration
	from ProjectManager PM2
	group by PM2.ProjId, PM2.MgrId
		)
select  Project.ProjName, Employee.EmpName
from (
	select T1.ProjId, T1.MgrId
	from T1 left outer join T2
	on T1.ProjId = T2.ProjId and T1.duration < T2.duration
	where T2.ProjId is null) T3, Employee, Project  
where T3.MgrId = Employee.EmpId and Project.ProjId = T3.ProjId;
 