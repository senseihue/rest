import { ExtractJwt, Strategy } from 'passport-jwt';
import { PassportStrategy } from '@nestjs/passport';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'fallback_secret', // Ideally from config
      passReqToCallback: true,
    });
  }

  async validate(
    req: { headers: { authorization?: string } },
    payload: { sub: string; username: string },
  ) {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      throw new UnauthorizedException('No token provided');
    }

    const token = authHeader.split(' ')[1];

    const existingToken = await this.prisma.authToken.findUnique({
      where: { token },
      include: { user: true },
    });

    if (!existingToken) {
      throw new UnauthorizedException('Token is invalid or logged out');
    }

    if (new Date() > existingToken.expireDate) {
      throw new UnauthorizedException('Token is expired');
    }

    // Return custom or exact user structure
    return {
      userId: existingToken.userId,
      username: payload.username,
      role: existingToken.user?.role,
    };
  }
}
