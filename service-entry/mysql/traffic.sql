drop procedure if exists dummy;

delimiter $$

create procedure dummy()
begin
  declare cnt int default 1;

  while cnt <= 10 do
    select current_time(), user(), database();
    show variables like "%version%";
    do sleep(1);
    set cnt = cnt + 1;
  end while;
end $$

delimiter ;

call dummy();
