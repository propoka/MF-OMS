import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  BadRequestException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { Roles } from '../common/decorators/roles.decorator';
import { Role } from '@prisma/client';
import { AuditLog } from '../common/decorators/audit-log.decorator';
import { CreateUserDto } from './dto/create-user.dto';
import * as bcrypt from 'bcryptjs';

@ApiTags('Users (Người dùng)')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(Role.ADMIN)
  @ApiOperation({ summary: 'Lấy danh sách người dùng (Chỉ Admin)' })
  findAll() {
    return this.usersService.findAll();
  }

  @Post()
  @Roles(Role.ADMIN)
  @AuditLog('CREATE', 'User')
  @ApiOperation({ summary: 'Tạo tài khoản mới (Chỉ Admin)' })
  async create(@Body() createUserDto: CreateUserDto) {
    const existing = await this.usersService.findByEmail(createUserDto.email);
    if (existing) {
      throw new BadRequestException('Email đã tồn tại trên hệ thống.');
    }

    const passwordHash = await bcrypt.hash(createUserDto.password, 10);

    return this.usersService.create({
      email: createUserDto.email,
      fullName: createUserDto.fullName,
      passwordHash,
      role: createUserDto.role || Role.STAFF,
    });
  }

  @Patch(':id/role')
  @Roles(Role.ADMIN)
  @AuditLog('UPDATE', 'User')
  @ApiOperation({ summary: 'Đổi quyền tài khoản (Chỉ Admin)' })
  updateRole(@Param('id') id: string, @Body() updateDto: { role: Role }) {
    if (!updateDto.role || !['ADMIN', 'STAFF'].includes(updateDto.role)) {
      throw new BadRequestException('Role không hợp lệ');
    }
    return this.usersService.updateRole(id, updateDto.role);
  }

  @Delete(':id')
  @Roles(Role.ADMIN)
  @AuditLog('DELETE', 'User')
  @ApiOperation({ summary: 'Xoá tài khoản (Chỉ Admin)' })
  remove(@Param('id') id: string) {
    return this.usersService.remove(id);
  }
}
