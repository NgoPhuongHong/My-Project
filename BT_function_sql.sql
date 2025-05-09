-- BAI TAP FUNCTION
--BT1: voi 1 ma sv, 1 ma khoa, kiem tra xem sv co thuoc khoa nay hay ko => tra ra dung hay sai

--cach binh thuong khong dung function
declare @masv varchar(10) --tao ra bien masv de input vao\
declare @makhoa varchar(10)
declare @ketqua varchar(10)
set @masv = '212003' -- nhap masv muon tim
set @makhoa = 'CNTT'
set @ketqua = 'False'
if(exists
	(
	select * from [dbo].[SinhVien] as sv
	left join [dbo].[Lop] as l
	on sv.MaLop = l.MaLop
	left join [dbo].[Khoa] as kh
	on l.MaKhoa = kh.MaKhoa
	where sv.MaSV = @masv and kh.MaKhoa = @makhoa)
  )
  set @ketqua = 'True'
else
  set @ketqua = 'False'
print @ketqua

/* dùng exists để kiểm tra sự tồn tại của hàm select, nếu select có trả ra kết qả => @ketqua = True, ngược lại nếu select ko co 
ket qua tra về (tức không có mã sv 212003 nào thuộc khoa CNTT cả)=> @ketqua = False */

--TAO VOI FUNCTION => dung function de co the tai su dung code
create function Check_masv_makhoa
(
	@masv varchar(10),
	@makhoa varchar(10)
)
returns varchar(10) --ket qua tra ra la kieu dl varchar(10) => kq tuc la True or Fale
as
begin
declare @ketqua varchar(10)
set @ketqua = 'False'
if(exists
	(
	select * from [dbo].[SinhVien] as sv
	left join [dbo].[Lop] as l
	on sv.MaLop = l.MaLop
	left join [dbo].[Khoa] as kh
	on l.MaKhoa = kh.MaKhoa
	where sv.MaSV = @masv and kh.MaKhoa = @makhoa)
  )
  set @ketqua = 'True'
else
  set @ketqua = 'False'
return @ketqua --thay cho print thi function can return
end
go
-- =>da tao function thanh cong
-- =>dua vao su dung
select dbo.Check_masv_makhoa('212003','CNTT')
select dbo.Check_masv_makhoa('212003','VL')
select dbo.Check_masv_makhoa('212002','CNTT')
--=> tai su dung nhieu lan, chi can truyen lai bien khac 


--BT2: Tinh diem thi sau cung cua 1 sinh vien trong 1 mon hoc cu the

create function Diem_thi2
(
	@masv varchar(10),
	@maMH varchar(10)
)
returns float
as
begin
	declare @diemthi float;
	set @diemthi = 0;

	/*declare @masv varchar(10);
	declare @maMH varchar(10);
	set @masv = '212001'
	set @maMH = 'THT01'*/

	select top 1 @diemthi = kq.Diem from [dbo].[KetQua] as kq
	where kq.MaSV = @masv and kq.MaMH = @maMH
	order by kq.Diem desc

return @diemthi
end
go 
select dbo.Diem_thi2 ('212001', 'THT02')

-- BT3: tinh diem TB cua 1 sinh vien (chu y: diem TB duoc tinh dua tren lan thi sau cung)
create function Diem_TB3
(
	@masv varchar(10)
)
returns float
as
begin
	declare @diem_tb float;
	set @diem_tb = 0;

	/*declare @masv varchar(10)
	set @masv = '212001'*/
	

	select @diem_tb = avg(distinct dbo.Diem_thi2(@masv,kq.MaMH)) 
	from [dbo].[KetQua] as kq
	where kq.MaSV = @masv
	--group by kq.MaMH
	
	
return @diem_tb
end
go
select dbo.Diem_TB3('212001')

--BT4: nhap vao 1 sinh vien va 1 mon hoc, tra  ve cac diem thi cua sv nay trong cac lan thi cuar mon do


create function Tra_cuu_diem1
(
	@masv varchar(10),
	@mamh varchar(10)
)
returns table
return select kq.Diem, kq.LanThi
	   from [dbo].[KetQua] as kq
	   where @masv = kq.MaSV and @mamh = kq.MaMH
go
select * from dbo.Tra_cuu_diem1('212001','THT01')

-- BT5: nhap vao 1 sinh vien, tra ve danh sach cac mon hoc ma sv nay phai hoc
create function mon_hoc1
(
	@masv varchar(10)
)
returns table
return select distinct mh.TenMH
	   from [dbo].[MonHoc] as mh
	   left join [dbo].[KetQua] as kq on mh.MaMH = kq.MaMH
	   where @masv= kq.MaSV
go
select * from dbo.mon_hoc1('212001')

