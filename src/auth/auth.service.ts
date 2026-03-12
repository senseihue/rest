import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma.service';
import { LoginDto } from './dto/login.dto';
import { User } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async validateUser(loginDto: LoginDto): Promise<User> {
    const user = await this.prisma.user.findFirst({
      where: {
        OR: [{ email: loginDto.username }, { login: loginDto.username }],
      },
    });

    if (!user) {
      throw new UnauthorizedException('Username or password incorrect');
    }

    // Since we're not focusing on hashing in this exact plan, we do a raw check.
    // In production, use bcrypt: await bcrypt.compare(loginDto.password, user.password)
    if (user.password !== loginDto.password) {
      throw new UnauthorizedException('Username or password incorrect');
    }

    return user;
  }

  async login(user: User) {
    const payload = {
      username: user.login || user.email,
      sub: user.id,
      role: user.role,
    };
    const token = this.jwtService.sign(payload);

    // Save token to DB
    const expireDate = new Date();
    expireDate.setHours(expireDate.getHours() + 1); // 1 hour expiration from JWT config

    await this.prisma.authToken.create({
      data: {
        token: token,
        expireDate: expireDate,
        userId: user.id,
      },
    });

    return {
      access_token: token,
      user: {
        id: user.id,
        login: user.login,
        email: user.email,
        role: user.role,
      },
    };
  }

  async logout(token: string) {
    const existing = await this.prisma.authToken.findUnique({
      where: { token },
    });
    if (existing) {
      await this.prisma.authToken.delete({
        where: { token },
      });
    }
  }
}
